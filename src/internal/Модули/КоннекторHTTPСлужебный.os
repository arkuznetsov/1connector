Функция ВызватьHTTPМетод(Сессия, Метод, URL, ДополнительныеПараметры) Экспорт
	
	Если ТипЗнч(ДополнительныеПараметры) <> Тип("Структура") Тогда
		ДополнительныеПараметры = Новый Структура;
	КонецЕсли;
	
	Запрос = Новый Структура;
	Запрос.Вставить("Метод", ВРег(Метод));
	Запрос.Вставить("URL", URL);
	Запрос.Вставить("Заголовки", ВыбратьЗначение(Неопределено, ДополнительныеПараметры, "Заголовки", Новый Соответствие));
	Запрос.Вставить("Файлы", ВыбратьЗначение(Неопределено, ДополнительныеПараметры, "Файлы", Новый Массив));
	Запрос.Вставить("Данные", ВыбратьЗначение(Неопределено, ДополнительныеПараметры, "Данные", Новый Структура));
	Запрос.Вставить("Json", ВыбратьЗначение(Неопределено, ДополнительныеПараметры, "Json", Новый Соответствие));
	Запрос.Вставить("ПараметрыЗапроса", ВыбратьЗначение(Неопределено, ДополнительныеПараметры, "ПараметрыЗапроса", Новый Структура));
	Запрос.Вставить("Аутентификация", ВыбратьЗначение(Неопределено, ДополнительныеПараметры, "Аутентификация", Новый Структура));
	Запрос.Вставить("Cookies", ВыбратьЗначение(Неопределено, ДополнительныеПараметры, "Cookies", Новый Массив));
	Запрос.Вставить("ПараметрыПреобразованияJSON", ВыбратьЗначение(Неопределено, ДополнительныеПараметры, "ПараметрыПреобразованияJSON", Неопределено));
	Запрос.Вставить("ПараметрыЗаписиJSON", ВыбратьЗначение(Неопределено, ДополнительныеПараметры, "ПараметрыЗаписиJSON", Неопределено));
	
	ПодготовленныйЗапрос = ПодготовитьЗапрос(Сессия, Запрос);
	
	РазрешитьПеренаправление = ?(ДополнительныеПараметры.Свойство("РазрешитьПеренаправление"), ДополнительныеПараметры.РазрешитьПеренаправление, ВРег(Метод) <> "HEAD");
	
	Настройки = Новый Структура;
	Настройки.Вставить("Таймаут", ПолучитьТаймаут(ДополнительныеПараметры));
	Настройки.Вставить("РазрешитьПеренаправление", РазрешитьПеренаправление);
	Настройки.Вставить("ПроверятьSSL", ?(ДополнительныеПараметры.Свойство("ПроверятьSSL"), ДополнительныеПараметры.ПроверятьSSL, Истина));
	Настройки.Вставить("КлиентскийСертификатSSL", ?(ДополнительныеПараметры.Свойство("КлиентскийСертификатSSL"), ДополнительныеПараметры.КлиентскийСертификатSSL, Неопределено));
	Настройки.Вставить("Прокси", ?(ДополнительныеПараметры.Свойство("Прокси"), ДополнительныеПараметры.Прокси, ПолучитьПроксиПоУмолчанию(ПодготовленныйЗапрос.URL)));
	Настройки.Вставить("ПараметрыПреобразованияJSON", Запрос.ПараметрыПреобразованияJSON);
	
	Ответ = ОтправитьЗапрос(Сессия, ПодготовленныйЗапрос, Настройки);
	
	Перенаправление = 0;
	Пока Перенаправление < Сессия.МаксимальноеКоличествоПеренаправлений Цикл
		Если Не Настройки.РазрешитьПеренаправление ИЛИ Не Ответ.ЭтоРедирект Тогда
			Возврат Ответ;
		КонецЕсли;
		
		НовыйURL = ПолучитьЗначениеЗаголовка("location", Ответ.Заголовки);
		НовыйURL = РаскодироватьСтроку(НовыйURL, СпособКодированияСтроки.URLВКодировкеURL);
		
		// Редирект без схемы
		Если СтрНачинаетсяС(НовыйURL, "//") Тогда
			СтруктураURL = РазобратьURL(Ответ.URL);
			НовыйURL = СтруктураURL.Схема + ":" + НовыйURL;
		КонецЕсли;
		
		СтруктураURL = РазобратьURL(НовыйURL);
		Если Не ЗначениеЗаполнено(СтруктураURL.Сервер) Тогда
			СтруктураURLОтвета = РазобратьURL(Ответ.URL);
			БазовыйURL = СтрШаблон("%1://%2", СтруктураURLОтвета.Схема, СтруктураURLОтвета.Сервер);
			Если ЗначениеЗаполнено(СтруктураURLОтвета.Порт) Тогда
				БазовыйURL = БазовыйURL + Формат(СтруктураURLОтвета.Порт, "ЧРГ=; ЧГ=");
			КонецЕсли;
			НовыйURL = БазовыйURL + НовыйURL;
		КонецЕсли;
		ПодготовленныйЗапрос.URL = КодироватьСтроку(НовыйURL, СпособКодированияСтроки.URLВКодировкеURL);
		ПодготовленныйЗапрос.HTTPЗапрос.АдресРесурса = СобратьАдресРесурса(РазобратьURL(НовыйURL), Неопределено);
		
		ПереопределитьМетод(ПодготовленныйЗапрос, Ответ);	
			
		// https://github.com/requests/requests/issues/1084
		Если Ответ.КодСостояния <> 307 И Ответ.КодСостояния <> 308 Тогда
			// https://github.com/requests/requests/issues/3490
			ПодготовленныйЗапрос.HTTPЗапрос.УстановитьТелоИзДвоичныхДанных(Base64Значение(""));
			ЗаголовкиДляУдаления = Новый Массив;
			Заголовки = СтрРазделить("content-length,content-type,transfer-encoding", ",", Ложь);
			Для Каждого Заголовок Из ПодготовленныйЗапрос.Заголовки Цикл
				Если Заголовки.Найти(НРег(Заголовок.Ключ)) <> Неопределено Тогда
					ЗаголовкиДляУдаления.Добавить(Заголовок.Ключ);
				КонецЕсли;
			КонецЦикла;
			Для Каждого ЗаголовокДляУдаления Из ЗаголовкиДляУдаления Цикл
				ПодготовленныйЗапрос.Заголовки.Удалить(ЗаголовокДляУдаления);
			КонецЦикла;
		    ПодготовленныйЗапрос.HTTPЗапрос.Заголовки = ПодготовленныйЗапрос.Заголовки;
		КонецЕсли;
		Для Каждого Заголовок Из ПодготовленныйЗапрос.Заголовки Цикл
			Если НРег(Заголовок.Ключ) = "cookie" Тогда
				ПодготовленныйЗапрос.Заголовки.Удалить(Заголовок.Ключ);
				Прервать;
			КонецЕсли;
		КонецЦикла;
		ПодготовленныйЗапрос.Cookies = ОбъединитьCookies(Сессия.Cookies, ПодготовленныйЗапрос.Cookies);
		ПодготовитьCookies(ПодготовленныйЗапрос);
		
		// INFO: по хорошему аутентификацию нужно привести к новых параметрам, но пока будем игнорировать.
		
		Ответ = ОтправитьЗапрос(Сессия, ПодготовленныйЗапрос, Настройки);
		
		Перенаправление = Перенаправление + 1;
	КонецЦикла;
	
	ВызватьИсключение("СлишкомМногоПеренаправлений");
	
КонецФункции

Функция ПолучитьТаймаут(ДополнительныеПараметры)
	
	Если ДополнительныеПараметры.Свойство("Таймаут") И ЗначениеЗаполнено(ДополнительныеПараметры.Таймаут) Тогда
		Таймаут = ДополнительныеПараметры.Таймаут;
	Иначе
		Таймаут = СтандартныйТаймаут();
	КонецЕсли;
	
	Возврат Таймаут;
	
КонецФункции

Функция ПолучитьПроксиПоУмолчанию(URL)
	
	Возврат Неопределено;
	
КонецФункции

Функция ПодготовитьЗапрос(Сессия, Запрос)
	
	Cookies = ОбъединитьCookies(ДозаполнитьCookie(Сессия.Cookies, Запрос.URL), ДозаполнитьCookie(Запрос.Cookies, Запрос.URL));
	
	ПодготовленныйЗапрос = Новый Структура;
	ПодготовленныйЗапрос.Вставить("Cookies", Cookies);
	ПодготовленныйЗапрос.Вставить("Аутентификация", ОбъединитьПараметрыАутентификации(Запрос.Аутентификация, Сессия.Аутентификация));
	ПодготовленныйЗапрос.Вставить("Метод", Запрос.Метод);
	ПодготовленныйЗапрос.Вставить("Заголовки", ОбъединитьЗаголовки(Запрос.Заголовки, Сессия.Заголовки));
	ПараметрыЗапроса = ОбъединитьПараметрыЗапроса(Запрос.ПараметрыЗапроса, Сессия.ПараметрыЗапроса);
	ПодготовленныйЗапрос.Вставить("ПараметрыЗапроса", ПараметрыЗапроса);
	ПодготовленныйЗапрос.Вставить("URL", ПодготовитьURL(Запрос.URL, ПараметрыЗапроса));
	
	ПодготовитьCookies(ПодготовленныйЗапрос);
	ПодготовитьТелоЗапроса(
		ПодготовленныйЗапрос,
		Запрос.Данные,
		Запрос.Файлы,
		Запрос.Json,
		Запрос.ПараметрыПреобразованияJSON,
		Запрос.ПараметрыЗаписиJSON);
	ПодготовитьАутентификацию(ПодготовленныйЗапрос);

	Возврат ПодготовленныйЗапрос;
	
КонецФункции

Функция ДозаполнитьCookie(Cookies, URL)
	
	СтруктураURL = РазобратьURL(URL);
	НовыеCookies = Новый Массив;
	Если ТипЗнч(Cookies) = Тип("Массив") Тогда
		Для Каждого Cookie Из Cookies Цикл
			НовыйCookie = КонструкторCookie(Cookie.Наименование, Cookie.Значение);
			ЗаполнитьЗначенияСвойств(НовыйCookie, Cookie);
			
			Если Не ЗначениеЗаполнено(НовыйCookie.Домен) Тогда
				НовыйCookie.Домен = СтруктураURL.Сервер;
			КонецЕсли;
			Если Не ЗначениеЗаполнено(НовыйCookie.Путь) Тогда
				НовыйCookie.Путь = "/";
			КонецЕсли;
			
			НовыеCookies.Добавить(НовыйCookie);
		КонецЦикла;
		
		Возврат НовыеCookies;
	КонецЕсли;
	
	Возврат Cookies;
	
КонецФункции

Процедура ДобавитьCookieВХранилище(ХранилищеCookies, Cookie, Замещать = Ложь)
	
	Если ХранилищеCookies.Получить(Cookie.Домен) = Неопределено Тогда
		ХранилищеCookies[Cookie.Домен] = Новый Соответствие;
	КонецЕсли;
	Если ХранилищеCookies[Cookie.Домен].Получить(Cookie.Путь) = Неопределено Тогда
		ХранилищеCookies[Cookie.Домен][Cookie.Путь] = Новый Соответствие;
	КонецЕсли;
	Если ХранилищеCookies[Cookie.Домен][Cookie.Путь].Получить(Cookie.Наименование) = Неопределено ИЛИ Замещать Тогда
		ХранилищеCookies[Cookie.Домен][Cookie.Путь][Cookie.Наименование] = Cookie;
	КонецЕсли;
	
КонецПроцедуры

Функция ДобавитьЛидирующуюТочку(Знач Домен)
	
	Если Не СтрНачинаетсяС(Домен, ".") Тогда
		Домен = "." + Домен;
	КонецЕсли;
	
	Возврат Домен;
	
КонецФункции

Функция ОтобратьCookiesДляЗапроса(СтруктураURL, Cookies)
	
	СерверВЗапросе = ДобавитьЛидирующуюТочку(СтруктураURL.Сервер);
	
	Результат = Новый Массив;
	Для Каждого Домен Из Cookies Цикл
		ДоменВCookie = ДобавитьЛидирующуюТочку(Домен.Ключ);
		Если Не СтрЗаканчиваетсяНа(СерверВЗапросе, Домен.Ключ) Тогда
			Продолжить;
		КонецЕсли;
		Для Каждого Путь Из Домен.Значение Цикл
			Если Не СтрНачинаетсяС(СтруктураURL.Путь, Путь.Ключ) Тогда
				Продолжить;
			КонецЕсли;
			Для Каждого Наименование Из Путь.Значение Цикл
				Если Наименование.Значение.ТолькоБезопасноеСоединение = Истина И СтруктураURL.Схема <> "https" Тогда
					Продолжить;
				КонецЕсли;
				// INFO: проверка срока действия игнорируется (Наименование.Значение.СрокДействия)
				Если ЗначениеЗаполнено(Наименование.Значение.Порт) Тогда
					// INFO: проверка порта игнорируется
				КонецЕсли;
				
				Результат.Добавить(Наименование.Значение);
			КонецЦикла;
		КонецЦикла;		
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ПодготовитьЗаголовокCookie(ПодготовленныйЗапрос)
	
	СтруктураURL = РазобратьURL(ПодготовленныйЗапрос.URL);
	
	Заголовок = "";
	Cookies = Новый Массив;
	Для Каждого Cookie Из ОтобратьCookiesДляЗапроса(СтруктураURL, ПодготовленныйЗапрос.Cookies) Цикл
		Cookies.Добавить(СтрШаблон("%1=%2", Cookie.Наименование, Cookie.Значение));	
	КонецЦикла;
	
	Возврат СтрСоединить(Cookies, "; ");
	
КонецФункции

Процедура ПодготовитьCookies(ПодготовленныйЗапрос)
	
	ЗаголовокCookie = ПодготовитьЗаголовокCookie(ПодготовленныйЗапрос);
	Если ЗначениеЗаполнено(ЗаголовокCookie) Тогда
		ПодготовленныйЗапрос.Заголовки["Cookie"] = ЗаголовокCookie;
	КонецЕсли;
	
КонецПроцедуры

Функция КодироватьПараметрыЗапроса(ПараметрыЗапроса)
	
	ЧастиПараметрыЗапроса = Новый Массив;
	Для Каждого Параметр Из ПараметрыЗапроса Цикл
		Если ТипЗнч(Параметр.Значение) = Тип("Массив") Тогда
			Значения = Параметр.Значение;
		Иначе
			Значения = Новый Массив;
			Значения.Добавить(Параметр.Значение);
		КонецЕсли;
		
		Для Каждого Значение Из Значения Цикл
			ЗначениеПараметра = КодироватьСтроку(Значение, СпособКодированияСтроки.URLВКодировкеURL);
			ЧастиПараметрыЗапроса.Добавить(СтрШаблон("%1=%2", Параметр.Ключ, ЗначениеПараметра));
		КонецЦикла;
	КонецЦикла;
	
	Возврат СтрСоединить(ЧастиПараметрыЗапроса, "&");
	
КонецФункции

Функция ПодготовитьURL(Знач URL, ПараметрыЗапроса = Неопределено)
	
	URL = СокрЛ(URL);
	
	СтруктураURL = РазобратьURL(URL);
	
	ПодготовленныйURL = СтруктураURL.Схема + "://";
	Если ЗначениеЗаполнено(СтруктураURL.Аутентификация.Пользователь) Тогда
		ПодготовленныйURL = ПодготовленныйURL 
			+ СтруктураURL.Аутентификация.Пользователь + ":"
			+ СтруктураURL.Аутентификация.Пароль + "@";
	КонецЕсли;
	ПодготовленныйURL = ПодготовленныйURL + СтруктураURL.Сервер;
	Если ЗначениеЗаполнено(СтруктураURL.Порт) Тогда
		ПодготовленныйURL = ПодготовленныйURL + ":" + Формат(СтруктураURL.Порт, "ЧРГ=; ЧГ=");
	КонецЕсли;
	
	ПодготовленныйURL = ПодготовленныйURL + СобратьАдресРесурса(СтруктураURL, ПараметрыЗапроса);
		
	Возврат ПодготовленныйURL;
	
КонецФункции

Функция ЗаголовкиВСтроку(Заголовки)
	
	РазделительСтрок = Символы.ВК + Символы.ПС;
	Строки = Новый Массив;
	
	СортированныеЗаголовки = "Content-Disposition,Content-Type,Content-Location";
	Для Каждого Ключ Из СтрРазделить(СортированныеЗаголовки, ",") Цикл
		Значение = ПолучитьЗначениеЗаголовка(Ключ, Заголовки);
		Если Значение <> Ложь И ЗначениеЗаполнено(Значение) Тогда
			Строки.Добавить(СтрШаблон("%1: %2", Ключ, Значение));
		КонецЕсли;
	КонецЦикла;
	
	Ключи = СтрРазделить(ВРег(СортированныеЗаголовки), ",");
	Для Каждого Заголовок Из Заголовки Цикл
		Если Ключи.Найти(ВРег(Заголовок.Ключ)) = Неопределено Тогда
			Строки.Добавить(СтрШаблон("%1: %2", Заголовок.Ключ, Заголовок.Значение));
		КонецЕсли;
	КонецЦикла;
	Строки.Добавить(РазделительСтрок);
	
	Возврат СтрСоединить(Строки, РазделительСтрок);
	
КонецФункции

Функция ПолучитьЗначениеПоКлючу(Структура, Ключ, ЗначениеПоУмолчанию = Неопределено)
	
	Значение = ЗначениеПоУмолчанию;
	Если ТипЗнч(Структура) = Тип("Структура") И Структура.Свойство(Ключ) Тогда
		Значение = Структура[Ключ];
	ИначеЕсли ТипЗнч(Структура) = Тип("Соответствие") И Структура.Получить(Ключ) <> Неопределено Тогда
		Значение = Структура.Получить(Ключ);
	КонецЕсли;
	
	Возврат Значение;
	
КонецФункции
	
Функция СоздатьПолеФормы(ИсходныеПараметры)
	
	Поле = Новый Структура("Имя,ИмяФайла,Данные,Тип,Заголовки");
	Поле.Имя = ИсходныеПараметры.Имя;                   
	Поле.Данные = ИсходныеПараметры.Данные;
	
	Поле.Тип = ПолучитьЗначениеПоКлючу(ИсходныеПараметры, "Тип");
	Поле.Заголовки = ПолучитьЗначениеПоКлючу(ИсходныеПараметры, "Заголовки", Новый Соответствие);
	Поле.ИмяФайла = ПолучитьЗначениеПоКлючу(ИсходныеПараметры, "ИмяФайла");
	
	Ключ = "Content-Disposition";
	Если ПолучитьЗначениеЗаголовка("content-disposition", Поле.Заголовки, Ключ) = Ложь Тогда
		Поле.Заголовки.Вставить("Content-Disposition", "form-data");	
	КонецЕсли;
	
	Части = Новый Массив;
	Части.Добавить(Поле.Заголовки[Ключ]);
	Части.Добавить(СтрШаблон("name=""%1""", Поле.Имя));
	Если ЗначениеЗаполнено(Поле.ИмяФайла) Тогда
		Части.Добавить(СтрШаблон("filename=""%1""", Поле.ИмяФайла));
	КонецЕсли;
	
	Поле.Заголовки[Ключ] = СтрСоединить(Части, "; ");
	Поле.Заголовки["Content-Type"] = Поле.Тип;
	
	Возврат Поле;
	
КонецФункции

Функция ЗакодироватьФайлы(HTTPЗапрос, Файлы, Данные)
	
	Части = Новый Массив;
	Если ЗначениеЗаполнено(Данные) Тогда
		Для Каждого Поле Из Данные Цикл
			Части.Добавить(СоздатьПолеФормы(Новый Структура("Имя,Данные", Поле.Ключ, Поле.Значение)));
		КонецЦикла;
	КонецЕсли;
	Если ТипЗнч(Файлы) = Тип("Массив") Тогда
		Для Каждого Файл Из Файлы Цикл
			Части.Добавить(СоздатьПолеФормы(Файл));
		КонецЦикла;
	Иначе
		Части.Добавить(СоздатьПолеФормы(Файлы));
	КонецЕсли;
	
	Разделитель = СтрЗаменить(Новый УникальныйИдентификатор, "-", "");
	РазделительСтрок = Символы.ВК + Символы.ПС;
	
	ЗаписьДанных = Новый ЗаписьДанных(
		HTTPЗапрос.ПолучитьТелоКакПоток(),
		КодировкаТекста.UTF8,
		ПорядокБайтов.LittleEndian,
		"",
		"",
		Ложь);
	Для Каждого Часть Из Части Цикл
		ЗаписьДанных.ЗаписатьСтроку("--" + Разделитель + РазделительСтрок);
		ЗаписьДанных.ЗаписатьСтроку(ЗаголовкиВСтроку(Часть.Заголовки));
		Если ТипЗнч(Часть.Данные) = Тип("ДвоичныеДанные") Тогда
			ЗаписьДанных.Записать(Часть.Данные);
		Иначе
			ЗаписьДанных.ЗаписатьСтроку(Часть.Данные);
		КонецЕсли;
		ЗаписьДанных.ЗаписатьСтроку(РазделительСтрок);		
	КонецЦикла;
	ЗаписьДанных.ЗаписатьСтроку("--" + Разделитель + "--" + РазделительСтрок);
	ЗаписьДанных.Закрыть();
	
	Возврат СтрШаблон("multipart/form-data; boundary=%1", Разделитель);
	
КонецФункции

Процедура ПодготовитьТелоЗапроса(ПодготовленныйЗапрос, Данные, Файлы, Json, ПараметрыПреобразованияJSON, ПараметрыЗаписиJSON)
	
	HTTPЗапрос = Новый HTTPЗапрос;
	HTTPЗапрос.АдресРесурса = СобратьАдресРесурса(
		РазобратьURL(ПодготовленныйЗапрос.URL), 
		ПодготовленныйЗапрос.ПараметрыЗапроса);
	Если ЗначениеЗаполнено(Файлы) ИЛИ ЗначениеЗаполнено(Данные) Тогда
		Если ЗначениеЗаполнено(Файлы) Тогда
			ContentType = ЗакодироватьФайлы(HTTPЗапрос, Файлы, Данные);
		ИначеЕсли ЗначениеЗаполнено(Данные) Тогда
			ContentType = "application/x-www-form-urlencoded";
			HTTPЗапрос.УстановитьТелоИзСтроки(
				КодироватьПараметрыЗапроса(Данные), 
				КодировкаТекста.UTF8, 
				ИспользованиеByteOrderMark.НеИспользовать);
		КонецЕсли;
	ИначеЕсли ЗначениеЗаполнено(Json) Тогда
		ContentType = "application/json";
		HTTPЗапрос.УстановитьТелоИзСтроки(
			ОбъектВJson(Json, ПараметрыПреобразованияJSON, ПараметрыЗаписиJSON), 
			КодировкаТекста.UTF8, 
			ИспользованиеByteOrderMark.НеИспользовать);
	КонецЕсли;
	ЗначениеЗаголовка = ПолучитьЗначениеЗаголовка("content-type", ПодготовленныйЗапрос.Заголовки);
	Если ЗначениеЗаголовка = Ложь И ЗначениеЗаполнено(ContentType) Тогда
		ПодготовленныйЗапрос.Заголовки.Вставить("Content-Type", ContentType);
	КонецЕсли;
	
	HTTPЗапрос.Заголовки = ПодготовленныйЗапрос.Заголовки;
	ПодготовленныйЗапрос.Вставить("HTTPЗапрос", HTTPЗапрос);
	
КонецПроцедуры

Процедура ПодготовитьАутентификацию(ПодготовленныйЗапрос)
	
	Если Не ЗначениеЗаполнено(ПодготовленныйЗапрос.Аутентификация) Тогда
		СтруктураURL = РазобратьURL(ПодготовленныйЗапрос.URL);
		Если ЗначениеЗаполнено(СтруктураURL.Аутентификация) Тогда
			ПодготовленныйЗапрос.Аутентификация = СтруктураURL.Аутентификация;	
		КонецЕсли;		
	КонецЕсли;
	
КонецПроцедуры

Функция ОбъединитьCookies(ГлавныйИсточник, ДополнительныйИсточник)
	
	Cookies = Новый Соответствие;
	Для Каждого Cookie Из ПреобразоватьХранилищеCookiesВМассивCookies(ГлавныйИсточник) Цикл
		ДобавитьCookieВХранилище(Cookies, Cookie, Ложь);
	КонецЦикла;
	Для Каждого Cookie Из ПреобразоватьХранилищеCookiesВМассивCookies(ДополнительныйИсточник) Цикл
		ДобавитьCookieВХранилище(Cookies, Cookie, Ложь);
	КонецЦикла;
	
	Возврат Cookies;
	
КонецФункции

Функция ПреобразоватьХранилищеCookiesВМассивCookies(ХранилищеCookies)
	
	Cookies = Новый Массив;
	Если ТипЗнч(ХранилищеCookies) = Тип("Массив") Тогда
		Для Каждого Cookie Из ХранилищеCookies Цикл
			НоваяCookie = КонструкторCookie();
			ЗаполнитьЗначенияСвойств(НоваяCookie, Cookie);
			Cookies.Добавить(НоваяCookie);
		КонецЦикла;
		
		Возврат Cookies;
	КонецЕсли;
	
	Для Каждого Домен Из ХранилищеCookies Цикл
		Для Каждого Путь Из Домен.Значение Цикл
			Для Каждого Наименование Из Путь.Значение Цикл
				Cookies.Добавить(Наименование.Значение);
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
	Возврат Cookies;
	
КонецФункции

Функция ОбъединитьПараметрыАутентификации(ГлавныйИсточник, ДополнительныйИсточник)
	
	ПараметрыАутентификации = Новый Структура;
	Если ТипЗнч(ГлавныйИсточник) = Тип("Структура") Тогда
		Для Каждого Параметр Из ГлавныйИсточник Цикл
			ПараметрыАутентификации.Вставить(Параметр.Ключ, Параметр.Значение);
		КонецЦикла;
	КонецЕсли;
	Если ТипЗнч(ДополнительныйИсточник) = Тип("Структура") Тогда
		Для Каждого Параметр Из ДополнительныйИсточник Цикл
			Если Не ПараметрыАутентификации.Свойство(Параметр) Тогда
				ПараметрыАутентификации.Вставить(Параметр.Ключ, Параметр.Значение);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат ПараметрыАутентификации;
	
КонецФункции

Функция ОбъединитьЗаголовки(ГлавныйИсточник, ДополнительныйИсточник)
	
	Заголовки = Новый Соответствие;
	Для Каждого Заголовок Из ГлавныйИсточник Цикл
		Заголовки.Вставить(Заголовок.Ключ, Заголовок.Значение);
	КонецЦикла;
	Для Каждого Заголовок Из ДополнительныйИсточник Цикл
		Если Заголовки.Получить(Заголовок.Ключ) = Неопределено Тогда
			Заголовки.Вставить(Заголовок.Ключ, Заголовок.Значение);
		КонецЕсли;
	КонецЦикла;
	
	Возврат Заголовки;
	
КонецФункции

Функция ОбъединитьПараметрыЗапроса(ГлавныйИсточник, ДополнительныйИсточник)
	
	ПараметрыЗапроса = Новый Соответствие;
	Если ТипЗнч(ГлавныйИсточник) = Тип("Структура") ИЛИ ТипЗнч(ГлавныйИсточник) = Тип("Соответствие") Тогда
		Для Каждого Параметр Из ГлавныйИсточник Цикл
			ПараметрыЗапроса.Вставить(Параметр.Ключ, Параметр.Значение);
		КонецЦикла;
	КонецЕсли;
	Если ТипЗнч(ДополнительныйИсточник) = Тип("Структура") ИЛИ ТипЗнч(ДополнительныйИсточник) = Тип("Соответствие") Тогда
		Для Каждого Параметр Из ДополнительныйИсточник Цикл
			Если ПараметрыЗапроса.Получить(Параметр) = Неопределено Тогда
				ПараметрыЗапроса.Вставить(Параметр.Ключ, Параметр.Значение);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат ПараметрыЗапроса;
	
КонецФункции

Функция ОтправитьHTTPЗапрос(Сессия, ПодготовленныйЗапрос, Настройки)
	
	Соединение = ПолучитьСоединение(
		РазобратьURL(ПодготовленныйЗапрос.URL), ПодготовленныйЗапрос.Аутентификация, Настройки);
	Возврат Соединение.ВызватьHTTPМетод(ПодготовленныйЗапрос.Метод, ПодготовленныйЗапрос.HTTPЗапрос);
	
КонецФункции

Функция ОтправитьЗапрос(Сессия, ПодготовленныйЗапрос, Настройки)
	
	Начало = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Ответ = ОтправитьHTTPЗапрос(Сессия, ПодготовленныйЗапрос, Настройки);
	
	ПодготовленныйОтвет = Новый ПодготовленныйОтвет(Ответ, Настройки.ПараметрыПреобразованияJSON);
	ПодготовленныйОтвет.ВремяВыполнения = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
	ПодготовленныйОтвет.Cookies = ИзвлечьCookies(Ответ.Заголовки, ПодготовленныйЗапрос.URL); 
	ПодготовленныйОтвет.Заголовки = Ответ.Заголовки;
	ПодготовленныйОтвет.ЭтоПостоянныйРедирект = ЭтоПостоянныйРедирект(Ответ.КодСостояния, Ответ.Заголовки);
	ПодготовленныйОтвет.ЭтоРедирект = ЭтоРедирект(Ответ.КодСостояния, Ответ.Заголовки);
	ПодготовленныйОтвет.Кодировка = ПолучитьКодировкуИзЗаголовков(Ответ.Заголовки);
	ПодготовленныйОтвет.КодСостояния = Ответ.КодСостояния;
	ПодготовленныйОтвет.URL = ПодготовленныйЗапрос.URL;
	
	Сессия.Cookies = ОбъединитьCookies(Сессия.Cookies, ПодготовленныйОтвет.Cookies);
	
	Возврат ПодготовленныйОтвет;
	
КонецФункции

Процедура ПереопределитьМетод(ПодготовленныйЗапрос, Ответ)
	
	Метод = ПодготовленныйЗапрос.Метод;

	// http://tools.ietf.org/html/rfc7231#section-6.4.4
	Если Ответ.КодСостояния = 303 И Метод <> "HEAD" Тогда
		Метод = "GET";
	КонецЕсли;
	
	// Поведение браузеров
	Если Ответ.КодСостояния = 302 И Метод <> "HEAD" Тогда
		Метод = "GET";
	КонецЕсли;
	
	Если Ответ.КодСостояния = 301 И Метод = "POST" Тогда
		Метод = "GET";
	КонецЕсли;
	
	ПодготовленныйЗапрос.Метод = Метод;
	
КонецПроцедуры	

Функция ИзвлечьCookies(Заголовки, URL)
	
	Cookies = Новый Соответствие;
	Для Каждого ОчереднойЗаголовок Из Заголовки Цикл
		Если НРег(ОчереднойЗаголовок.Ключ) = "set-cookie" Тогда
			Для Каждого ЗаголовокCookie Из РазбитьНаОтдельныеЗаголовкиCookies(ОчереднойЗаголовок.Значение) Цикл
				Cookie = РаспарситьCookie(ЗаголовокCookie, URL);
				ДобавитьCookieВХранилище(Cookies, Cookie);
			КонецЦикла;
		КонецЕсли;
	КонецЦикла;	
	
	Возврат Cookies;
	
КонецФункции

Функция РазбитьНаОтдельныеЗаголовкиCookies(Знач Заголовок)
	
	Заголовки = Новый Массив;
	
	Если Не ЗначениеЗаполнено(Заголовок) Тогда
		Возврат Заголовки;
	КонецЕсли;
	
	ЗапчастиЗаголовков = СтрРазделить(Заголовок, ",", Ложь);
	
	ОтдельныйЗаголовок = ЗапчастиЗаголовков[0];
	Для Индекс = 1 По ЗапчастиЗаголовков.ВГраница() Цикл
		ТочкаяСЗапятой = СтрНайти(ЗапчастиЗаголовков[Индекс], ";");
		Равно = СтрНайти(ЗапчастиЗаголовков[Индекс], "=");
		Если ТочкаяСЗапятой И Равно И Равно < ТочкаяСЗапятой Тогда
			Заголовки.Добавить(ОтдельныйЗаголовок);
			ОтдельныйЗаголовок = ЗапчастиЗаголовков[Индекс];
		Иначе
			ОтдельныйЗаголовок = ОтдельныйЗаголовок + ЗапчастиЗаголовков[Индекс];
		КонецЕсли;
	КонецЦикла;
	Заголовки.Добавить(ОтдельныйЗаголовок);	
	
	Возврат Заголовки;
	
КонецФункции

Функция КонструкторCookie(Наименование = "", Значение = Неопределено)
	
	Возврат Новый Структура(
		"Наименование, Значение, Домен, Путь, Порт, СрокДействия, ТолькоБезопасноеСоединение", 
		Наименование, 
		Значение,
		"",
		"");
	
КонецФункции

Функция РаспарситьCookie(Заголовок, URL)
	
	Cookie = КонструкторCookie();
	Индекс = 0;
	
	Для Каждого Параметр Из СтрРазделить(Заголовок, ";", Ложь) Цикл
		Индекс = Индекс + 1;
		Параметр = СокрЛП(Параметр);
		
		Если Индекс = 1 Тогда
			Части = СтрРазделить(Параметр, "=", Ложь);
			Если НЕ ЗначениеЗаполнено(Части[0]) Тогда
				Возврат Cookie;                                           
			КонецЕсли;
			Cookie.Наименование = Части[0];
			Если Части.Количество() > 1 Тогда
				Cookie.Значение = Части[1];
			КонецЕсли;		
			Продолжить;	
		КонецЕсли;
		
		Если СтрНайти(Параметр, "=") Тогда
			Части = СтрРазделить(Параметр, "=", Ложь);
			Ключ = НРег(Части[0]);
			Значение = Части[1];
		Иначе
			Ключ = НРег(Параметр);
		КонецЕсли;
		
		
		Если Ключ = "domain" Тогда
			Cookie.Домен = Значение;
		ИначеЕсли Ключ = "path" Тогда
			Cookie.Путь = Значение;
		ИначеЕсли Ключ = "secure" Тогда
			Cookie.ТолькоБезопасноеСоединение = Истина;
		Иначе
			Продолжить; // INFO: другие параметры пока игнорируются
		КонецЕсли; 
	КонецЦикла;
	
	СтруктураURL = РазобратьURL(URL);
	Если Не ЗначениеЗаполнено(Cookie.Домен) Тогда
		Cookie.Домен = СтруктураURL.Сервер;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(Cookie.Порт) И ЗначениеЗаполнено(СтруктураURL.Порт) Тогда
		Cookie.Порт = СтруктураURL.Порт;
	КонецЕсли;
	
	Возврат Cookie;
	
КонецФункции

Функция ПолучитьЗначениеЗаголовка(Заголовок, ВсеЗаголовки, Ключ = Неопределено)
	
	Для Каждого ОчереднойЗаголовок Из ВсеЗаголовки Цикл
		Если НРег(ОчереднойЗаголовок.Ключ) = НРег(Заголовок) Тогда
			Ключ = ОчереднойЗаголовок.Ключ;
			Возврат ОчереднойЗаголовок.Значение;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

Функция ЭтоПостоянныйРедирект(КодСостояния, Заголовки)
	
	Возврат ЕстьЗаголовокLocation(Заголовки) И (КодСостояния = 301 ИЛИ КодСостояния = 308);
	
КонецФункции

Функция ЭтоРедирект(КодСостояния, Заголовки)
	
	СостоянияРедиректа = Новый Массив;
	СостоянияРедиректа.Добавить(301);
	СостоянияРедиректа.Добавить(302);
	СостоянияРедиректа.Добавить(303);
	СостоянияРедиректа.Добавить(307);
	СостоянияРедиректа.Добавить(308);
	
	Возврат ЕстьЗаголовокLocation(Заголовки) И СостоянияРедиректа.Найти(КодСостояния) <> Неопределено;
	
КонецФункции

Функция ЕстьЗаголовокLocation(Заголовки)
	
	Возврат ПолучитьЗначениеЗаголовка("location", Заголовки) <> Ложь;
	
КонецФункции

Функция ПолучитьКодировкуИзЗаголовков(Заголовки)
	
	Значение = ПолучитьЗначениеЗаголовка("content-type", Заголовки);
	
	Если Значение = Ложь Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Опции = Новый Соответствие;
	ТипСодержимого = Неопределено;
	
	Значение = ";" + Значение;
	Пока Сред(Значение, 1, 1) = ";" Цикл
		Значение = Сред(Значение, 2);
		Конец = СтрНайти(Значение, ";");
		Пока Конец И (СтрСчитать(Значение, """", 1, Конец) - СтрСчитать(Значение, "\""", 1, Конец)) % 2 Цикл
			Конец = СтрНайти(Значение, ";", НаправлениеПоиска.СНачала, Конец + 1);	
		КонецЦикла;
		Если Конец = 0 Тогда
			Конец = СтрДлина(Значение) + 1;
		КонецЕсли;
		ЧастьСтрока = Сред(Значение, 1, Конец - 1);
		Значение = Сред(Значение, Конец);	
		
		Если Не ЗначениеЗаполнено(ТипСодержимого) Тогда
			ТипСодержимого = ЧастьСтрока;
			Продолжить;
		КонецЕсли;
		
		Индекс = СтрНайти(ЧастьСтрока, "=");
		Если Индекс Тогда
			ИмяОпции = НРег(СокрЛП(Сред(ЧастьСтрока, 1, Индекс - 1)));
			Опция = СокрЛП(Сред(ЧастьСтрока, Индекс + 1));
			Если СтрДлина(Опция) >= 2 И Сред(Опция, 1, 1) = """" И Сред(Опция, СтрДлина(Опция) - 1) = """" Тогда
				Опция = Сред(Опция, 2, СтрДлина(Опция) - 2);
				Опция = СтрЗаменить(Опция, "\\", "\");
				Опция = СтрЗаменить(Опция, "\""", """");
			КонецЕсли;
			Опции[ИмяОпции] = Опция;
		КонецЕсли;
	КонецЦикла;
	
	Если Опции.Получить("charset") <> Неопределено Тогда
		Опция = Опции["charset"];
		Если (Сред(Опция, 1, 1) = """" И Сред(Опция, СтрДлина(Опция) - 1) = """")
			ИЛИ (Сред(Опция, 1, 1) = "'" И Сред(Опция, СтрДлина(Опция) - 1) = "'") Тогда
			Опция = Сред(Опция, 2, СтрДлина(Опция) - 2); 
		КонецЕсли;
		Возврат Опция;
	КонецЕсли;	
	Если СтрНайти(ТипСодержимого, "text") Тогда
		Возврат "ISO-8859-1";
	КонецЕсли;	
	
КонецФункции

Функция СтрСчитать(Строка, ЧтоСчитать, Начало, Конец)
	
	Возврат СтрЧислоВхождений(Сред(Строка, Начало, Конец), ЧтоСчитать);
	
КонецФункции

Функция СобратьАдресРесурса(СтруктураURL, ПараметрыЗапроса)
	
	АдресРесурса = СтруктураURL.Путь;
	
	ОбъединенныеПараметрыЗапроса = ОбъединитьПараметрыЗапроса(ПараметрыЗапроса, СтруктураURL.ПараметрыЗапроса);
	Если ЗначениеЗаполнено(ОбъединенныеПараметрыЗапроса) Тогда
		АдресРесурса = АдресРесурса + "?" + КодироватьПараметрыЗапроса(ОбъединенныеПараметрыЗапроса);
	КонецЕсли;
	Если ЗначениеЗаполнено(СтруктураURL.Фрагмент) Тогда
		АдресРесурса = АдресРесурса + "#" + СтруктураURL.Фрагмент;
	КонецЕсли;
	
	Возврат АдресРесурса;
	
КонецФункции

Функция ПолучитьСоединение(ПараметрыСоединения, Аутентификация, ДополнительныеПараметры)
	
	Если ПараметрыСоединения.Схема = "https" Тогда
		Если Не ЗначениеЗаполнено(ПараметрыСоединения.Порт) Тогда
			ПараметрыСоединения.Порт = 443;
		КонецЕсли;
	ИначеЕсли ПараметрыСоединения.Схема = "http" Тогда
		Если Не ЗначениеЗаполнено(ПараметрыСоединения.Порт) Тогда
			ПараметрыСоединения.Порт = 80;
		КонецЕсли;	
	КонецЕсли;
	
	Пользователь = "";
	Пароль = "";
	Если ЗначениеЗаполнено(Аутентификация) Тогда
		Пользователь = Аутентификация.Пользователь;
		Пароль = Аутентификация.Пароль;
	КонецЕсли;
	
	Возврат Новый HTTPСоединение(
		ПараметрыСоединения.Схема + "://" + ПараметрыСоединения.Сервер,
		ПараметрыСоединения.Порт,
		Пользователь, Пароль,
		ДополнительныеПараметры.Прокси, 
		ДополнительныеПараметры.Таймаут);	
	
КонецФункции

Функция ВыбратьЗначение(Значение1, Значение2, Ключ, ЗначениеПоУмолчанию)
	
	Если ЗначениеЗаполнено(Значение1) Тогда
		Возврат Значение1;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Значение2) И ЗначениеЗаполнено(Ключ) 
		И ТипЗнч(Значение2) = Тип("Структура")
		И Значение2.Свойство(Ключ) И ЗначениеЗаполнено(Значение2[Ключ]) Тогда
		Возврат Значение2[Ключ];
	КонецЕсли;
	
	Возврат ЗначениеПоУмолчанию;
	
КонецФункции

Функция РазделитьПоПервомуНайденномуРазделителю(Строка, Разделители)
	
	МинимальныйИндекс = СтрДлина(Строка);
	ПервыйРазделитель = "";
	
	Для Каждого Разделитель Из Разделители Цикл
		Индекс = СтрНайти(Строка, Разделитель);
		Если Индекс = 0 Тогда
			Продолжить;
		КонецЕсли;
		Если Индекс < МинимальныйИндекс Тогда
			МинимальныйИндекс = Индекс;
			ПервыйРазделитель = Разделитель;
		КонецЕсли;
	КонецЦикла;
	
	Результат = Новый Массив;
	Если ЗначениеЗаполнено(ПервыйРазделитель) Тогда
		Результат.Добавить(Лев(Строка, МинимальныйИндекс - 1));
		Результат.Добавить(Сред(Строка, МинимальныйИндекс + СтрДлина(ПервыйРазделитель)));
		Результат.Добавить(ПервыйРазделитель);
	Иначе
		Результат.Добавить(Строка);
		Результат.Добавить("");
		Результат.Добавить(Неопределено);
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Процедура РазбитьСтрокуПоРазделителю(ИзвлекаемаяЧасть, ОстальнаяЧасть, Разделитель, Инверсия = Ложь)
	
	Индекс = СтрНайти(ОстальнаяЧасть, Разделитель);
	Если Индекс Тогда
		ИзвлекаемаяЧасть = Лев(ОстальнаяЧасть, Индекс - 1);
		ОстальнаяЧасть = Сред(ОстальнаяЧасть, Индекс + СтрДлина(Разделитель));
		Если Инверсия Тогда
			ДляОбмена = ИзвлекаемаяЧасть;
			ИзвлекаемаяЧасть = ОстальнаяЧасть;
			ОстальнаяЧасть = ДляОбмена;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Функция РазобратьURL(Знач URL)

	ДопустимыеСхемы = СтрРазделить("http,https", ",");
	
	Схема = "";
	URLБезСхемы = URL;
	РазбитьСтрокуПоРазделителю(Схема, URLБезСхемы, "://");
	Если ДопустимыеСхемы.Найти(НРег(Схема)) <> Неопределено Тогда
		URL = URLБезСхемы;
	Иначе
		Схема = "";
	КонецЕсли;
	
	Путь = "";
	Результат = РазделитьПоПервомуНайденномуРазделителю(URL, СтрРазделить("/,?,#", ","));
	URL = Результат[0];
	Если ЗначениеЗаполнено(Результат[2]) Тогда
		Путь = Результат[2] + Результат[1];
	КонецЕсли;
	
	Аутентификация = Новый Структура("Пользователь, Пароль", "", "");
	АутентификацияСтрока = "";
	РазбитьСтрокуПоРазделителю(АутентификацияСтрока, URL, "@");
	Если ЗначениеЗаполнено(АутентификацияСтрока) Тогда
		АутентификацияЧасти = СтрРазделить(АутентификацияСтрока, ":");
		Аутентификация.Пользователь = АутентификацияЧасти[0];
		Аутентификация.Пароль       = АутентификацияЧасти[1];
	КонецЕсли;	

	// IPv6
	Сервер = "";
	РазбитьСтрокуПоРазделителю(Сервер, URL, "]");
	Если ЗначениеЗаполнено(Сервер) Тогда
		Сервер = Сервер + "]";
	КонецЕсли;
	
	URL = СтрЗаменить(URL, "/", "");
	
	Порт = "";
	РазбитьСтрокуПоРазделителю(Порт, URL, ":", Истина);
	
	Если Не ЗначениеЗаполнено(Сервер) Тогда
		Сервер = URL;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Порт) Тогда 
		Порт = Число(Порт);
	Иначе
		Порт = 0;	
	КонецЕсли;
	
	Фрагмент = "";
	РазбитьСтрокуПоРазделителю(Фрагмент, Путь, "#", Истина);
	
	ПараметрыЗапроса = Новый Соответствие;
	Запрос = "";
	РазбитьСтрокуПоРазделителю(Запрос, Путь, "?", Истина);
	Запрос = РаскодироватьСтроку(Запрос, СпособКодированияСтроки.URLВКодировкеURL);
	Для Каждого СтрокаКлючРавноПараметр Из СтрРазделить(Запрос, "&", Ложь) Цикл

		ПозицияРавно = СтрНайти(СтрокаКлючРавноПараметр, "=");
		Если ПозицияРавно = 0 Тогда
			Ключ = СтрокаКлючРавноПараметр;
			Значение = Неопределено;
		Иначе
			Ключ = Лев(СтрокаКлючРавноПараметр, ПозицияРавно - 1);
			Значение = Сред(СтрокаКлючРавноПараметр, ПозицияРавно + 1);
		КонецЕсли;

		Если ПараметрыЗапроса.Получить(Ключ) <> Неопределено Тогда
			Если ТипЗнч(Значение) = Тип("Массив") Тогда
				ПараметрыЗапроса[Ключ].Добавить(Значение);
			Иначе
				Значения = Новый Массив;
				Значения.Добавить(ПараметрыЗапроса[Ключ]);
				Значения.Добавить(Значение);
				ПараметрыЗапроса[Ключ] = Значения;
			КонецЕсли;
		Иначе
			ПараметрыЗапроса.Вставить(Ключ, Значение);
		КонецЕсли;
		
	КонецЦикла;
	
	Если Не ЗначениеЗаполнено(Схема) Тогда
		Схема = "http";
	КонецЕсли;
	Результат = Новый Структура;
	Результат.Вставить("Схема", Схема);
	Результат.Вставить("Аутентификация", Аутентификация);
	Результат.Вставить("Сервер", Сервер);
	Результат.Вставить("Порт", Порт);
	Результат.Вставить("Путь", ?(ЗначениеЗаполнено(Путь), Путь, "/"));
	Результат.Вставить("ПараметрыЗапроса", ПараметрыЗапроса);
	Результат.Вставить("Фрагмент", Фрагмент);

	Возврат Результат;
	
КонецФункции

Функция ОбъектВJson(Объект, Знач ПараметрыПреобразования, Знач ПараметрыЗаписи) Экспорт
	
	ПараметрыПреобразованияJSON = ДополнитьПараметрыПреобразованияJSON(ПараметрыПреобразования);

	ПараметрыЗаписи = ДополнитьПараметрыЗаписиJSON(ПараметрыЗаписи);
	
	ПараметрыЗаписиJSON = Новый ПараметрыЗаписиJSON(
		ПараметрыЗаписи.ПереносСтрок,
		ПараметрыЗаписи.СимволыОтступа,
		ПараметрыЗаписи.ИспользоватьДвойныеКавычки,
		ПараметрыЗаписи.ЭкранированиеСимволов,
		ПараметрыЗаписи.ЭкранироватьУгловыеСкобки,
		ПараметрыЗаписи.ЭкранироватьРазделителиСтрок,
		ПараметрыЗаписи.ЭкранироватьАмперсанд,
		ПараметрыЗаписи.ЭкранироватьОдинарныеКавычки,
		ПараметрыЗаписи.ЭкранироватьСлеш);
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку(ПараметрыЗаписиJSON);
	ЗаписатьJSON(ЗаписьJSON, Объект);

	Возврат ЗаписьJSON.Закрыть();
	
КонецФункции

Функция JsonВОбъект(Json, ПараметрыПреобразования) Экспорт
	
	ПараметрыПреобразованияJSON = ДополнитьПараметрыПреобразованияJSON(ПараметрыПреобразования);
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(Json);
	
	Объект = ПрочитатьJSON(
		ЧтениеJSON, 
		ПараметрыПреобразованияJSON.ПрочитатьВСоответствие,
		ПараметрыПреобразованияJSON.ИменаСвойствСоЗначениямиДата,
		ПараметрыПреобразованияJSON.ФорматДатыJSON);
	ЧтениеJSON.Закрыть();
	
	Возврат Объект;

КонецФункции

Функция ДополнитьПараметрыПреобразованияJSON(ПараметрыПреобразования)
	
	ПараметрыПреобразованияJSON = ПолучитьПараметрыПреобразованияJSONПоУмолчанию();
	Если ЗначениеЗаполнено(ПараметрыПреобразования) Тогда
		Для Каждого Параметр Из ПараметрыПреобразования Цикл
			Если ПараметрыПреобразованияJSON.Свойство(Параметр.Ключ) Тогда
				ПараметрыПреобразованияJSON.Вставить(Параметр.Ключ, Параметр.Значение);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат ПараметрыПреобразованияJSON;
	
КонецФункции

Функция ДополнитьПараметрыЗаписиJSON(ПараметрыЗаписи)
	
	ПараметрыЗаписиJSON = ПолучитьПараметрыЗаписиJSONПоУмолчанию();
	Если ЗначениеЗаполнено(ПараметрыЗаписи) Тогда
		Для Каждого Параметр Из ПараметрыЗаписи Цикл
			Если ПараметрыЗаписиJSON.Свойство(Параметр.Ключ) Тогда
				ПараметрыЗаписиJSON.Вставить(Параметр.Ключ, Параметр.Значение);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	
	Возврат ПараметрыЗаписиJSON;
	
КонецФункции

Функция РазбитьСтрокуПоСтроке(Знач Строка, Разделитель)
	
	Результат = Новый Массив;
	Пока Истина Цикл
		Позиция = СтрНайти(Строка, Разделитель);
		Если Позиция = 0 И ЗначениеЗаполнено(Строка) Тогда
			Результат.Добавить(Строка);
			Прервать;
		КонецЕсли;
		
		ПерваяЧасть = Лев(Строка, Позиция - СтрДлина(Разделитель) + 1);
		Результат.Добавить(ПерваяЧасть);
		Строка = Сред(Строка, Позиция + СтрДлина(Разделитель));
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция СтандартныйТаймаут()
	
	Возврат 30;
	
КонецФункции

Функция ПолучитьПараметрыПреобразованияJSONПоУмолчанию()
	
	ПараметрыПреобразованияПоУмолчанию = Новый Структура;
	ПараметрыПреобразованияПоУмолчанию.Вставить("ПрочитатьВСоответствие", Истина);
	ПараметрыПреобразованияПоУмолчанию.Вставить("ФорматДатыJSON", ФорматДатыJSON.ISO);
	ПараметрыПреобразованияПоУмолчанию.Вставить("ИменаСвойствСоЗначениямиДата", Новый Массив());
	
	Возврат ПараметрыПреобразованияПоУмолчанию;
	
КонецФункции

Функция ПолучитьПараметрыЗаписиJSONПоУмолчанию()
	
	ПараметрыЗаписиJSONПоУмолчанию = Новый Структура;
	ПараметрыЗаписиJSONПоУмолчанию.Вставить("ПереносСтрок", ПереносСтрокJSON.Авто);
	ПараметрыЗаписиJSONПоУмолчанию.Вставить("СимволыОтступа", " ");
	ПараметрыЗаписиJSONПоУмолчанию.Вставить("ИспользоватьДвойныеКавычки", Истина);
	ПараметрыЗаписиJSONПоУмолчанию.Вставить("ЭкранированиеСимволов", ЭкранированиеСимволовJSON.Нет);
	ПараметрыЗаписиJSONПоУмолчанию.Вставить("ЭкранироватьУгловыеСкобки", Ложь);
	ПараметрыЗаписиJSONПоУмолчанию.Вставить("ЭкранироватьРазделителиСтрок", Истина);
	ПараметрыЗаписиJSONПоУмолчанию.Вставить("ЭкранироватьАмперсанд", Ложь);
	ПараметрыЗаписиJSONПоУмолчанию.Вставить("ЭкранироватьОдинарныеКавычки", Ложь);
	ПараметрыЗаписиJSONПоУмолчанию.Вставить("ЭкранироватьСлеш", Ложь);
	
	Возврат ПараметрыЗаписиJSONПоУмолчанию;
	
КонецФункции