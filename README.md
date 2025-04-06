Инструкция по по запуску

1. Установите и запустите docker
2. Перейдите в директорию ws_virtual-device

3. В файл device_tokens.txt добавьте токены, каждый начиная с новой строки.

4. 
Запуск под bash
```bash
./manage.sh build && ./manage.sh up && ./manage.sh logs
```
Запуск под windows
```bash
./manage.bat build && ./manage.bat up && ./manage.bat logs
```

5. 
Остановка контейнеров под bash
```bash
./manage.sh down
```

Остановка контейнеров под windows
```bash
./manage.bat down
```