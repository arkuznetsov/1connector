#Использовать asserts
#Использовать "../src"

Функция ПолучитьСписокТестов(МенеджерТестирования) Экспорт
	
	МассивТестов = Новый Массив;
	Если ЗначениеЗаполнено(ПеременныеСреды()["ENABLE_LOCAL_TESTS"]) Тогда
		МассивТестов.Добавить("ТестДолжен_ПроверитьЧтоРаботаетPing");
		МассивТестов.Добавить("ТестДолжен_ПроверитьЧтоРаботаетПовторПослеОшибкиПодключения");
		МассивТестов.Добавить("ТестДолжен_ПроверитьЧтоРаботаетПовторПослеОшибки502");
		МассивТестов.Добавить("ТестДолжен_ПроверитьЧтоРаботаетПовторСУчетомЗаголовкаRetryAfterDate");
		МассивТестов.Добавить("ТестДолжен_ПроверитьЧтоРаботаетПовторСУчетомЗаголовкаRetryAfterDuration");
	КонецЕсли;

	Возврат МассивТестов;

КонецФункции

Процедура ТестДолжен_ПроверитьЧтоРаботаетПовторСУчетомЗаголовкаRetryAfterDuration() Экспорт
	
	ПовторятьДляКодовСостояний = Новый Массив;
	ПовторятьДляКодовСостояний.Добавить(КодыСостоянияHTTP.СервисНедоступен_503);
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("X-ID", Строка(Новый УникальныйИдентификатор));
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("Таймаут", 1);
	ДополнительныеПараметры.Вставить("МаксимальноеКоличествоПовторов", 5);
	ДополнительныеПараметры.Вставить("КоэффициентЭкспоненциальнойЗадержки", 2);
	
	ДополнительныеПараметры.Вставить("Заголовки", Заголовки);
		
	URL = "http://127.0.0.1:5000/retry_after_duration";
	Ответ = КоннекторHTTP.Get(URL, Неопределено, ДополнительныеПараметры);

	Ожидаем.Что(Ответ.КодСостояния).Равно(200);
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЧтоРаботаетПовторСУчетомЗаголовкаRetryAfterDate() Экспорт
	
	ПовторятьДляКодовСостояний = Новый Массив;
	ПовторятьДляКодовСостояний.Добавить(КодыСостоянияHTTP.СервисНедоступен_503);
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("X-ID", Строка(Новый УникальныйИдентификатор));
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("Таймаут", 1);
	ДополнительныеПараметры.Вставить("МаксимальноеКоличествоПовторов", 5);
	ДополнительныеПараметры.Вставить("КоэффициентЭкспоненциальнойЗадержки", 2);
	
	ДополнительныеПараметры.Вставить("Заголовки", Заголовки);
		
	URL = "http://127.0.0.1:5000/retry_after_date";
	Ответ = КоннекторHTTP.Get(URL, Неопределено, ДополнительныеПараметры);
	
	Ожидаем.Что(Ответ.КодСостояния).Равно(200);
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЧтоРаботаетПовторПослеОшибки502() Экспорт

	ПовторятьДляКодовСостояний = Новый Массив;
	ПовторятьДляКодовСостояний.Добавить(КодыСостоянияHTTP.ОшибочныйШлюз_502);
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("X-ID", Строка(Новый УникальныйИдентификатор));
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("Таймаут", 1);
	ДополнительныеПараметры.Вставить("МаксимальноеКоличествоПовторов", 5);
	ДополнительныеПараметры.Вставить("ПовторятьДляКодовСостояний", ПовторятьДляКодовСостояний);
	
	ДополнительныеПараметры.Вставить("Заголовки", Заголовки);
		
	URL = "http://127.0.0.1:5000/retry_502";
	Ответ = КоннекторHTTP.Get(URL, Неопределено, ДополнительныеПараметры);
	
	Ожидаем.Что(Ответ.КодСостояния).Равно(200);
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЧтоРаботаетПовторПослеОшибкиПодключения() Экспорт

	ПовторятьДляКодовСостояний = Новый Массив;
	ПовторятьДляКодовСостояний.Добавить(КодыСостоянияHTTP.ОшибочныйШлюз_502);
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("X-ID", Строка(Новый УникальныйИдентификатор));
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("Таймаут", 1);
	ДополнительныеПараметры.Вставить("МаксимальноеКоличествоПовторов", 2);
	ДополнительныеПараметры.Вставить("ПовторятьДляКодовСостояний", ПовторятьДляКодовСостояний);
	
	ДополнительныеПараметры.Вставить("Заголовки", Заголовки);
	
	Начало = ТекущаяУниверсальнаяДатаВМиллисекундах();
	URL = "http://127.0.0.1:5001/non_existent_resource";
	Попытка
		КоннекторHTTP.Get(URL, Неопределено, ДополнительныеПараметры);
	Исключение
		Длительность = ТекущаяУниверсальнаяДатаВМиллисекундах() - Начало;
	КонецПопытки;

	Ожидаем.Что(Длительность).БольшеИлиРавно(3000);
	Ожидаем.Что(Длительность).Меньше(7000);
	
КонецПроцедуры

Процедура ТестДолжен_ПроверитьЧтоРаботаетPing() Экспорт

	URL = "http://127.0.0.1:5000/ping";
	Ответ = КоннекторHTTP.Get(URL, Неопределено, Новый Структура("Таймаут", 1));
	
	Ожидаем.Что(Ответ.КодСостояния).Равно(200);
	
КонецПроцедуры
