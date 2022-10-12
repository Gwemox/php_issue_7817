# php_issue_7817

Example of code that produces errors after a reset of the opcache.
https://github.com/php/php-src/issues/7817
# How to reproduce it?

```bash
docker-compose up --force-recreate
```
1. Open: http://localhost:8089/
2. Open: http://localhost:8089/debug_cache_clear.php
3. Open: http://localhost:8089/
4. Watch PHP-FPM logs in terminal

Example :
```log
web_1    | [12-Oct-2022 17:42:31] NOTICE: PHP message: PHP Warning:  Can't preload already declared class ReflectionEnum in /var/www/app/vendor/laminas/laminas-code/polyfill/ReflectionEnumPolyfill.php on line 8
web_1    | [12-Oct-2022 17:42:32] NOTICE: fpm is running, pid 1
web_1    | [12-Oct-2022 17:42:32] NOTICE: ready to handle connections
web_1    | 127.0.0.1 -  12/Oct/2022:17:42:32 +0000 "GET /index.php" 404
web_1    | 127.0.0.1 -  12/Oct/2022:17:42:35 +0000 "GET /debug_cache_clear.php" 200
web_1    | Assertion failed: ((execute_data)->opline) >= ((execute_data)->func)->op_array.opcodes && ((execute_data)->opline) < ((execute_data)->func)->op_array.opcodes + ((execute_data)->func)->op_array.last (./jit/zend_jit_trace.c: zend_jit_trace_exit: 8067)
web_1    | [12-Oct-2022 17:42:36] WARNING: [pool www] child 38 exited on signal 6 (SIGABRT - core dumped) after 4.697921 seconds from start
web_1    | [12-Oct-2022 17:42:36] NOTICE: [pool www] child 40 started

```