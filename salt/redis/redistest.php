<?php
$redis = new Redis();
try {
    $redis->connect('127.0.0.1','6379', 2.5, NULL, 150);
    $key = 'myKey';
//    $value = array('val1' => 'myValue1',
//                    'val2' => 'Value2');
    $value = 'CHOSS';
    $ttl = 3600;
    $redis->setex( $key, $ttl, $value );
    $value = $redis->get($key);
    var_dump($value);
} catch(RedisException $e) {
    var_dump($e);
}
$redis->close();
?>
