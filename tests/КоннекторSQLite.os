#Использовать ".."

#Использовать reflector

Перем Коннектор;

Процедура ПередЗапускомТеста() Экспорт
	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "tests", "fixtures", "СущностьСоВсемиТипамиКолонок.os"), "СущностьСоВсемиТипамиКолонок");
	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "tests", "fixtures", "СущностьБезГенерируемогоИдентификатора.os"), "СущностьБезГенерируемогоИдентификатора");
	ПодключитьСценарий(ОбъединитьПути(ТекущийКаталог(), "tests", "fixtures", "АвтоинкрементныйКлючБезКолонок.os"), "АвтоинкрементныйКлючБезКолонок");
	
	Коннектор = Новый КоннекторSQLite();
	СтрокаСоединения = "Data Source=:memory:";
	// СтрокаСоединения = "Data Source=test.db";
	Коннектор.Открыть(СтрокаСоединения, Новый Массив);
КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт
	Коннектор.Закрыть();
КонецПроцедуры

&Тест
Процедура КоннекторSQLiteРеализуетИнтерфейсКоннектора() Экспорт
	ИнтерфейсОбъекта = Новый ИнтерфейсОбъекта();
	ИнтерфейсОбъекта.ИзОбъекта(Тип("АбстрактныйКоннектор"));
	
	РефлекторОбъекта = Новый РефлекторОбъекта(Тип("КоннекторSQLite"));
	РефлекторОбъекта.РеализуетИнтерфейс(ИнтерфейсОбъекта, Истина);
КонецПроцедуры

&Тест
Процедура Сохранить() Экспорт
	
	МодельДанных = Новый МодельДанных();
	ОбъектМодели = МодельДанных.СоздатьОбъектМодели(Тип("СущностьСоВсемиТипамиКолонок"));
	Коннектор.ИнициализироватьТаблицу(ОбъектМодели);

	ЗависимаяСущность = Новый СущностьСоВсемиТипамиКолонок;
	ЗависимаяСущность.Целое = 2;
	
	ЗависимыйМассив = Новый Массив;
	ЗависимыйМассив.Добавить("Строка1");
	ЗависимыйМассив.Добавить("Строка2");

	ЗависимаяСтруктура = Новый Структура();
	ЗависимаяСтруктура.Вставить("Ключ1", "Значение1");
	ЗависимаяСтруктура.Вставить("Ключ2", "Значение2");

	Сущность = Новый СущностьСоВсемиТипамиКолонок;
	Сущность.Целое = 1;
	Сущность.Дробное = 1.2;
	Сущность.БулевоИстина = Истина;
	Сущность.БулевоЛожь = Ложь;
	Сущность.Строка = "Строка";
	Сущность.Дата = Дата(2018, 1, 1);
	Сущность.Время = Дата(1, 1, 1, 10, 53, 20);
	Сущность.ДатаВремя = Дата(2018, 1, 1, 10, 53, 20);
	Сущность.Ссылка = ЗависимаяСущность;
	Сущность.Массив = ЗависимыйМассив;
	Сущность.Структура = ЗависимаяСтруктура;
	
	Коннектор.Сохранить(ОбъектМодели, ЗависимаяСущность);
	Коннектор.Сохранить(ОбъектМодели, Сущность);
	
	ТекстЗапроса = СтрШаблон(
		"SELECT * FROM %1 WHERE %2 = %3", 
		ОбъектМодели.ИмяТаблицы(),
		ОбъектМодели.Идентификатор().ИмяКолонки,
		Сущность.Целое
	);
	РезультатЗапроса = Коннектор.ВыполнитьЗапрос(ТекстЗапроса);
	ДанныеИзБазы = РезультатЗапроса[0];
	
	Ожидаем.Что(ДанныеИзБазы.Целое, "Сущность.Целое сохранилось корректно").Равно(Сущность.Целое);
	Ожидаем.Что(ДанныеИзБазы.Дробное, "Сущность.Дробное сохранилось корректно").Равно(Сущность.Дробное);
	Ожидаем.Что(ДанныеИзБазы.БулевоИстина, "Сущность.БулевоИстина сохранилось корректно").Равно(Сущность.БулевоИстина);
	Ожидаем.Что(ДанныеИзБазы.БулевоЛожь, "Сущность.БулевоЛожь сохранилось корректно").Равно(Сущность.БулевоЛожь);
	Ожидаем.Что(ДанныеИзБазы.Строка, "Сущность.Строка сохранилось корректно").Равно(Сущность.Строка);
	Ожидаем.Что(ДанныеИзБазы.Дата, "Сущность.Дата сохранилось корректно").Равно(Сущность.Дата);
	Ожидаем.Что(ДанныеИзБазы.Время, "Сущность.Время сохранилось корректно").Равно(Сущность.Время);
	Ожидаем.Что(ДанныеИзБазы.ДатаВремя, "Сущность.ДатаВремя сохранилось корректно").Равно(Сущность.ДатаВремя);
	Ожидаем.Что(ДанныеИзБазы.Ссылка, "Сущность.Ссылка сохранилось корректно").Равно(Сущность.Ссылка.Целое);

	ТекстЗапроса = СтрШаблон(
		"SELECT * FROM %1 WHERE ref = %2", 
		ОбъектМодели.ИмяТаблицы() + "_Массив",
		Сущность.Целое
	);
	РезультатЗапроса = Коннектор.ВыполнитьЗапрос(ТекстЗапроса);
	Ожидаем.Что(РезультатЗапроса, "Сохранилось две строки зависимого массива").ИмеетДлину(2);
	ДанныеИзБазы1 = РезультатЗапроса[0];
	Ожидаем.Что(РезультатЗапроса[0].key, "Сохранился ключ первого элемента массива").Равно(0);
	Ожидаем.Что(РезультатЗапроса[0].value, "Сохранилось значение первого элемента массива").Равно(ЗависимыйМассив[0]);
	
	Ожидаем.Что(РезультатЗапроса[1].key, "Сохранился ключ второго элемента массива").Равно(1);
	Ожидаем.Что(РезультатЗапроса[1].value, "Сохранилось значение второго элемента массива").Равно(ЗависимыйМассив[1]);
	
	ТекстЗапроса = СтрШаблон(
		"SELECT * FROM %1 WHERE ref = %2", 
		ОбъектМодели.ИмяТаблицы() + "_Структура",
		Сущность.Целое
	);
	РезультатЗапроса = Коннектор.ВыполнитьЗапрос(ТекстЗапроса);
	Ожидаем.Что(РезультатЗапроса, "Сохранилось две строки зависимой структуры").ИмеетДлину(2);
	ДанныеИзБазы1 = РезультатЗапроса[0];
	Ожидаем.Что(РезультатЗапроса[0].key, "Сохранился ключ первого элемента структуры").Равно("Ключ1");
	Ожидаем.Что(РезультатЗапроса[0].value, "Сохранилось значение первого элемента структуры").Равно(ЗависимаяСтруктура.Ключ1);
	
	Ожидаем.Что(РезультатЗапроса[1].key, "Сохранился ключ второго элемента структуры").Равно("Ключ2");
	Ожидаем.Что(РезультатЗапроса[1].value, "Сохранилось значение второго элемента структуры").Равно(ЗависимаяСтруктура.Ключ2);
	
КонецПроцедуры

&Тест
Процедура ПолучитьЗначенияКолонокСущности() Экспорт
	МодельДанных = Новый МодельДанных();
	ОбъектМодели = МодельДанных.СоздатьОбъектМодели(Тип("СущностьСоВсемиТипамиКолонок"));
	Коннектор.ИнициализироватьТаблицу(ОбъектМодели);
	
	ЗависимаяСущность = Новый СущностьСоВсемиТипамиКолонок;
	ЗависимаяСущность.Целое = 2;
	
	Сущность = Новый СущностьСоВсемиТипамиКолонок;
	Сущность.Целое = 1;
	Сущность.Дробное = 1.2;
	Сущность.БулевоИстина = Истина;
	Сущность.БулевоЛожь = Ложь;
	Сущность.Строка = "Строка";
	Сущность.Дата = Дата(2018, 1, 1);
	Сущность.Время = Дата(1, 1, 1, 10, 53, 20);
	Сущность.ДатаВремя = Дата(2018, 1, 1, 10, 53, 20);
	Сущность.Ссылка = ЗависимаяСущность;
	
	Коннектор.Сохранить(ОбъектМодели, ЗависимаяСущность);
	Коннектор.Сохранить(ОбъектМодели, Сущность);
	
	МассивОтборов = Новый Массив;
	МассивОтборов.Добавить(Новый ЭлементОтбора("Целое", ВидСравнения.Равно, Сущность.Целое));

	НайденныеСтроки = Коннектор.НайтиСтрокиВТаблице(ОбъектМодели, МассивОтборов);
	ЗначенияКолонок = НайденныеСтроки[0];

	Ожидаем.Что(ЗначенияКолонок.Получить("Целое"), "ЗначенияКолонок.Целое получено корректно").Равно(Сущность.Целое);
	Ожидаем.Что(ЗначенияКолонок.Получить("Дробное"), "ЗначенияКолонок.Дробное получено корректно").Равно(Сущность.Дробное);
	Ожидаем.Что(ЗначенияКолонок.Получить("БулевоИстина"), "ЗначенияКолонок.БулевоИстина получено корректно").Равно(Сущность.БулевоИстина);
	Ожидаем.Что(ЗначенияКолонок.Получить("БулевоЛожь"), "ЗначенияКолонок.БулевоЛожь получено корректно").Равно(Сущность.БулевоЛожь);
	Ожидаем.Что(ЗначенияКолонок.Получить("Строка"), "ЗначенияКолонок.Строка получено корректно").Равно(Сущность.Строка);
	Ожидаем.Что(ЗначенияКолонок.Получить("Дата"), "ЗначенияКолонок.Дата получено корректно").Равно(Сущность.Дата);
	Ожидаем.Что(ЗначенияКолонок.Получить("Время"), "ЗначенияКолонок.Время получено корректно").Равно(Сущность.Время);
	Ожидаем.Что(ЗначенияКолонок.Получить("ДатаВремя"), "ЗначенияКолонок.ДатаВремя получено корректно").Равно(Сущность.ДатаВремя);
	Ожидаем.Что(ЗначенияКолонок.Получить("Ссылка"), "ЗначенияКолонок.Ссылка получено корректно").Равно(Сущность.Ссылка.Целое);
КонецПроцедуры

&Тест
Процедура ПоискСоСложнымОтбором() Экспорт

	МодельДанных = Новый МодельДанных();
	ОбъектМодели = МодельДанных.СоздатьОбъектМодели(Тип("СущностьБезГенерируемогоИдентификатора"));
	Коннектор.ИнициализироватьТаблицу(ОбъектМодели);

	Сущность = Новый СущностьБезГенерируемогоИдентификатора;
	Сущность.ВнутреннийИдентификатор = 1;
	Коннектор.Сохранить(ОбъектМодели, Сущность);
	
	Сущность = Новый СущностьБезГенерируемогоИдентификатора;
	Сущность.ВнутреннийИдентификатор = 2;
	Коннектор.Сохранить(ОбъектМодели, Сущность);
	
	Сущность = Новый СущностьБезГенерируемогоИдентификатора;
	Сущность.ВнутреннийИдентификатор = 3;
	Коннектор.Сохранить(ОбъектМодели, Сущность);
	
	ЭлементОтбора = Новый ЭлементОтбора("Идентификатор", ВидСравнения.Больше, 1);
	МассивОтборов = Новый Массив;
	МассивОтборов.Добавить(ЭлементОтбора);
	
	НайденныеСтроки = Коннектор.НайтиСтрокиВТаблице(ОбъектМодели, МассивОтборов);
	Ожидаем.Что(НайденныеСтроки, "Сущности нашлись с одним отбором").ИмеетДлину(2);
	
	МассивОтборов = Новый Массив;
	МассивОтборов.Добавить(Новый ЭлементОтбора("Идентификатор", ВидСравнения.Больше, 1));
	МассивОтборов.Добавить(Новый ЭлементОтбора("Идентификатор", ВидСравнения.Меньше, 3));
	
	НайденныеСтроки = Коннектор.НайтиСтрокиВТаблице(ОбъектМодели, МассивОтборов);
	Ожидаем.Что(НайденныеСтроки, "Сущность нашлась с массивов отборов").ИмеетДлину(1);
	
КонецПроцедуры

&Тест
Процедура СозданиеМинимальнойСущности() Экспорт
	МодельДанных = Новый МодельДанных();
	ОбъектМодели = МодельДанных.СоздатьОбъектМодели(Тип("АвтоинкрементныйКлючБезКолонок"));
	Коннектор.ИнициализироватьТаблицу(ОбъектМодели);
	
	Сущность = Новый АвтоинкрементныйКлючБезКолонок();
	Коннектор.Сохранить(ОбъектМодели, Сущность);
	
	Ожидаем.Что(Сущность.Идентификатор, "Идентификатор сущности без колонок заполнился без ошибок").Больше(0);
КонецПроцедуры

&Тест
Процедура УдалениеСущности() Экспорт
	МодельДанных = Новый МодельДанных();
	ОбъектМодели = МодельДанных.СоздатьОбъектМодели(Тип("АвтоинкрементныйКлючБезКолонок"));
	Коннектор.ИнициализироватьТаблицу(ОбъектМодели);
	
	Сущность = Новый АвтоинкрементныйКлючБезКолонок();
	Коннектор.Сохранить(ОбъектМодели, Сущность);
	
	Коннектор.Удалить(ОбъектМодели, Сущность);
	
	ТекстЗапроса = СтрШаблон(
		"SELECT * FROM %1 WHERE %2 = %3", 
		ОбъектМодели.ИмяТаблицы(),
		ОбъектМодели.Идентификатор().ИмяКолонки,
		Сущность.Идентификатор
	);
	РезультатЗапроса = Коннектор.ВыполнитьЗапрос(ТекстЗапроса);
	Ожидаем.Что(РезультатЗапроса, "Сущность удалилась").ИмеетДлину(0);
	
КонецПроцедуры

// TODO: Больше тестов на непосредственно коннектор
ПередЗапускомТеста();
Сохранить();
ПослеЗапускаТеста();
