# 1connector - удобный HTTP-клиент для oscript

[![Stars](https://img.shields.io/github/stars/vbondarevsky/1connector.svg?label=Github%20%E2%98%85&a)](https://github.com/vbondarevsky/1connector/stargazers)
[![Release](https://img.shields.io/github/tag/vbondarevsky/1connector.svg?label=Last%20release&a)](https://github.com/vbondarevsky/1connector/releases)
[![Чат по движку OneScript и библиотеке пакетов oscript-library](https://github.com/Patrolavia/telegram-badge/blob/master/chat.svg)](https://t.me/oscript_library)

[![Build Status](https://travis-ci.org/vbondarevsky/1connector.svg?branch=master)](https://travis-ci.org/vbondarevsky/1connector)

Библиотека берет на себя всю рутину работы с HTTP запросами. 
Буквально в одну строку можно получать данные, отправлять, не заботясь о необходимости конструирования URL, кодирования данных и т.п. 
В общем библиотека очень мощная и проста в использовании.

## Пример работы
```bsl
Результат = КоннекторHTTP.Get("https://api.github.com/events").Json();
Результат = КоннекторHTTP.Get("https://api.github.com/events").Текст();
Результат = КоннекторHTTP.Get("https://api.github.com/events").ДвоичныеДанные();
```

## Возможности
Основные возможности библиотеки:
- Передача параметров в строку запроса (в URL)
- Удобная работа с запросами и ответами в формате `JSON`
- Отправка данных формы (полей формы), `application/x-www-form-urlencoded`
- Отправка данных формы (полей формы и файлов), `multipart/form-data`
- Прозрачная поддержка ответов, закодированных `GZip`
- `Basic` и `Digest` аутентификация
- Автоматическое разрешение редиректов
- Установка и чтение Cookies
- Работа в рамках сессии с сохранением состояния (cookies, аутентификация и пр.)
- И многое другое

## Требования
Платформа **1.1.1** и выше.

## Установка

Для установки необходимо:
* Скачать файл 1connector-*.ospx из раздела [releases](https://github.com/vbondarevsky/1connector/releases)
* Воспользоваться командой:

```
opm install -f <ПутьКФайлу>
```
или установить с хаба пакетов

```
opm install 1connector
```

## Публичный интерфейс

[Документация публичного интерфейса](https://github.com/vbondarevsky/1connector/blob/develop/docs/README.md)

## Лицензия

Смотри файл [LICENSE](https://github.com/vbondarevsky/1connector/blob/develop/LICENSE).
