<?php

$TOKEN = getenv('UPLOAD_API_TOKEN');
$BASE_URL = getenv('UPLOAD_API_BASE_URL');

if (!$TOKEN || !$BASE_URL) {
    http_response_code(500);
    echo json_encode(['error' => 'Servidor não configurado'], JSON_UNESCAPED_UNICODE);
    exit;
}

$headers = getallheaders();
$tokenRecebido = $headers['X-API-TOKEN'] ?? null;

if ($tokenRecebido !== $TOKEN) {
    http_response_code(401);
    echo json_encode(['error' => 'Não autorizado'], JSON_UNESCAPED_UNICODE);
    exit;
}


header('Content-Type: application/json');

$produtoId = $_POST['produto_id'] ?? null;

if (!$produtoId || !isset($_FILES['file'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Parâmetros inválidos'], JSON_UNESCAPED_UNICODE);
    exit;
}

// segurança básica: só letras e números
if (!preg_match('/^[a-zA-Z0-9_-]+$/', $produtoId)) {
    http_response_code(400);
    echo json_encode(['error' => 'ID do produto inválido'], JSON_UNESCAPED_UNICODE);
    exit;
}

// valida tipo
$mime = mime_content_type($_FILES['file']['tmp_name']);
$permitidos = ['image/jpeg', 'image/png', 'image/webp'];

if (!in_array($mime, $permitidos)) {
    http_response_code(400);
    echo json_encode(['error' => 'Tipo de imagem não permitido'], JSON_UNESCAPED_UNICODE);
    exit;
}

$ext = match ($mime) {
    'image/png'  => 'png',
    'image/webp' => 'webp',
    default      => 'jpg',
};

$destino = __DIR__ . "/images/{$produtoId}.{$ext}";

// sobrescreve se existir
if (!move_uploaded_file($_FILES['file']['tmp_name'], $destino)) {
    http_response_code(500);
    echo json_encode(['error' => 'Erro ao salvar imagem'], JSON_UNESCAPED_UNICODE);
    exit;
}

$url = rtrim($BASE_URL, '/') . "/images/{$produtoId}.{$ext}";

echo json_encode([
    'success' => true,
    'url' => $url
]);
