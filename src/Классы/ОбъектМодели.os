Перем ТипСущности;
Перем ИмяТаблицы;
Перем Колонки;
Перем Идентификатор;

Перем МодельДанных;

Процедура ПриСозданииОбъекта(ПТипСущности, ПМодельДанных)
	
	МодельДанных = ПМодельДанных;
	ТипСущности = ПТипСущности;

	ОписаниеТиповСтрока = Новый ОписаниеТипов("Строка");
	ОписаниеТиповБулево = Новый ОписаниеТипов("Булево");

	ИмяТаблицы = "";
	Колонки = Новый ТаблицаЗначений;
	Колонки.Колонки.Добавить("ИмяПоля", ОписаниеТиповСтрока);
	Колонки.Колонки.Добавить("ИмяКолонки", ОписаниеТиповСтрока);
	Колонки.Колонки.Добавить("ТипКолонки", ОписаниеТиповСтрока);
	Колонки.Колонки.Добавить("ГенерируемоеЗначение", ОписаниеТиповБулево);
	Колонки.Колонки.Добавить("Идентификатор", ОписаниеТиповБулево);
	Колонки.Колонки.Добавить("ТипСсылки");

	РефлекторОбъекта = Новый РефлекторОбъекта(ТипСущности);
	МетодСущность = РефлекторОбъекта.ПолучитьТаблицуМетодов("Сущность", Ложь)[0];
	
	АннотацияСущность = МетодСущность.Аннотации.Найти("сущность", "Имя");
	ПараметрИмяТаблицы = АннотацияСущность.Параметры.Найти("ИмяТаблицы", "Имя");
	ИмяТаблицы = ?(ПараметрИмяТаблицы = Неопределено, Строка(ТипСущности), ПараметрИмяТаблицы.Значение);
	
	// TODO: Работа с аннотациями через свойства
	ТаблицаСвойств = РефлекторОбъекта.ПолучитьТаблицуСвойств();
	Для Каждого Свойство Из ТаблицаСвойств Цикл
		ДанныеОКолонке = НовыйДанныеОКолонке();
		ДанныеОКолонке.ИмяПоля = Свойство.Имя;
		
		Аннотации = Свойство.Аннотации;
		АннотацияКолонка = Аннотации.Найти("Колонка", "Имя");
		ЗаполнитьИмяКолонки(ДанныеОКолонке, АннотацияКолонка);
		ЗаполнитьТипКолонки(ДанныеОКолонке, АннотацияКолонка);
		ЗаполнитьТипСсылки(ДанныеОКолонке, АннотацияКолонка);
		
		Если Аннотации.Найти("Идентификатор", "Имя") <> Неопределено Тогда
			ДанныеОКолонке.Идентификатор = Истина;
			Идентификатор = ДанныеОКолонке;
		КонецЕсли;

		Если Аннотации.Найти("ГенерируемоеЗначение", "Имя") <> Неопределено Тогда
			ДанныеОКолонке.ГенерируемоеЗначение = Истина;
		КонецЕсли;

		ЗаполнитьЗначенияСвойств(Колонки.Добавить(), ДанныеОКолонке);
	КонецЦикла;
	
КонецПроцедуры

Функция ИмяТаблицы() Экспорт
	Возврат ИмяТаблицы;
КонецФункции

Функция Колонки() Экспорт
	Возврат Колонки.Скопировать();
КонецФункции

Функция Идентификатор() Экспорт
	Возврат Новый ФиксированнаяСтруктура(Идентификатор);
КонецФункции

Функция МодельДанных() Экспорт
	Возврат МодельДанных;
КонецФункции

Функция ТипСущности() Экспорт
	Возврат ТипСущности;
КонецФункции

Функция ПолучитьЗначениеИдентификатора(Сущность) Экспорт
	ЗначениеИдентификатора = ПолучитьЗначениеПоля(Сущность, Идентификатор().ИмяПоля);
	Возврат ЗначениеИдентификатора;
КонецФункции

Функция ПолучитьЗначениеПоля(Сущность, ИмяПоля) Экспорт
	ЗначениеПоля = Вычислить("Сущность." + ИмяПоля);
	Возврат ЗначениеПоля;
КонецФункции

Функция ПолучитьПриведенноеЗначениеПоля(Сущность, ИмяПоля) Экспорт
	ЗначениеПоля = ПолучитьЗначениеПоля(Сущность, ИмяПоля);
		
	Колонка = Колонки().Найти(ИмяПоля, "ИмяПоля");
	
	Если Колонка.ТипКолонки = ТипыКолонок.Ссылка Тогда
		ОбъектМоделиСсылки = МодельДанных.Получить(Колонка.ТипСсылки);
		Если ЗначениеПоля = Неопределено Тогда
			ЗначениеПоля = ОбъектМоделиСсылки.ПривестиЗначениеПоля(ЗначениеПоля, ОбъектМоделиСсылки.Идентификатор().ИмяПоля);
		Иначе
			ЗначениеПоля = ОбъектМоделиСсылки.ПолучитьЗначениеИдентификатора(ЗначениеПоля);
		КонецЕсли;
	Иначе 
		ЗначениеПоля = ПривестиЗначениеПоля(ЗначениеПоля, ИмяПоля);
	КонецЕсли;
	
	Возврат ЗначениеПоля;
КонецФункции

Функция ПривестиЗначениеПоля(ЗначениеПоля, ИмяПоля) Экспорт
	Колонка = Колонки().Найти(ИмяПоля, "ИмяПоля");
	
	КартаОписанийТипов = СоответствиеТиповМоделиОписанийТипов();
	
	ОписаниеТипов = КартаОписанийТипов.Получить(Колонка.ТипКолонки);
	Возврат ОписаниеТипов.ПривестиЗначение(ЗначениеПоля);
КонецФункции

Процедура УстановитьЗначениеКолонкиВПоле(Сущность, ИмяКолонки, ЗначениеПоля) Экспорт

	// TODO: Дублирование кода ПривестиЗначениеПоля, только вместо имени поля имя колонки.
	КартаОписанийТипов = СоответствиеТиповМоделиОписанийТипов();
	
	Колонка = Колонки().Найти(ИмяКолонки, "ИмяКолонки");
	Если Колонка.ТипКолонки = ТипыКолонок.Ссылка Тогда
		УстанавливаемоеЗначениеПоля = ЗначениеПоля;
	Иначе
		ОписаниеТипов = КартаОписанийТипов.Получить(Колонка.ТипКолонки);	
		УстанавливаемоеЗначениеПоля = ОписаниеТипов.ПривестиЗначение(ЗначениеПоля);
	КонецЕсли;
	
	Выполнить("Сущность." + Колонка.ИмяПоля + " = УстанавливаемоеЗначениеПоля;");
	
КонецПроцедуры

Функция НовыйДанныеОКолонке()
	ДанныеОКолонке = Новый Структура;
	ДанныеОКолонке.Вставить("ИмяПоля", "");
	ДанныеОКолонке.Вставить("ИмяКолонки", "");
	ДанныеОКолонке.Вставить("ТипКолонки", "");
	ДанныеОКолонке.Вставить("ГенерируемоеЗначение", Ложь);
	ДанныеОКолонке.Вставить("Идентификатор");
	ДанныеОКолонке.Вставить("ТипСсылки");
	Возврат ДанныеОКолонке;
КонецФункции

Процедура ЗаполнитьИмяКолонки(ДанныеОКолонке, АннотацияКолонка)
	
	ЗначениеПоУмолчанию = ДанныеОКолонке.ИмяПоля;

	Если АннотацияКолонка = Неопределено ИЛИ АннотацияКолонка.Параметры = Неопределено Тогда
		ИмяКолонки = ЗначениеПоУмолчанию;
	Иначе
		ПараметрИмяКолонки = АннотацияКолонка.Параметры.Найти("Имя", "Имя");
		Если ПараметрИмяКолонки = Неопределено ИЛИ ПараметрИмяКолонки.Значение = Неопределено Тогда
			ИмяКолонки = ЗначениеПоУмолчанию;
		Иначе
			ИмяКолонки = ПараметрИмяКолонки.Значение;	
		КонецЕсли;
	КонецЕсли;
	
	ДанныеОКолонке.ИмяКолонки = ИмяКолонки;
КонецПроцедуры

Процедура ЗаполнитьТипКолонки(ДанныеОКолонке, АннотацияКолонка)
	
	ЗначениеПоУмолчанию = ТипыКолонок.Строка;
	
	Если АннотацияКолонка = Неопределено ИЛИ АннотацияКолонка.Параметры = Неопределено Тогда
		ТипКолонки = ЗначениеПоУмолчанию;
	Иначе
		ПараметрТипКолонки = АннотацияКолонка.Параметры.Найти("Тип", "Имя");
		Если ПараметрТипКолонки = Неопределено ИЛИ ПараметрТипКолонки.Значение = Неопределено Тогда
			ТипКолонки = ЗначениеПоУмолчанию;
		Иначе
			ТипКолонки = ПараметрТипКолонки.Значение;	
		КонецЕсли;
	КонецЕсли;

	ДанныеОКолонке.ТипКолонки = ТипКолонки;
КонецПроцедуры

Процедура ЗаполнитьТипСсылки(ДанныеОКолонке, АннотацияКолонка)
	
	ЗначениеПоУмолчанию = Неопределено;
	
	Если АннотацияКолонка = Неопределено ИЛИ АннотацияКолонка.Параметры = Неопределено Тогда
		ТипСсылки = ЗначениеПоУмолчанию;
	ИначеЕсли ДанныеОКолонке.ТипКолонки <> ТипыКолонок.Ссылка Тогда
		ТипСсылки = ЗначениеПоУмолчанию;
	Иначе
		ПараметрТипСсылки = АннотацияКолонка.Параметры.Найти("ТипСсылки", "Имя");
		Если ПараметрТипСсылки = Неопределено Тогда
			ТипСсылки = ЗначениеПоУмолчанию;
		Иначе
			ТипСсылки = Тип(ПараметрТипСсылки.Значение);	
		КонецЕсли;
	КонецЕсли;
	
	ДанныеОКолонке.ТипСсылки = ТипСсылки;
КонецПроцедуры

Функция СоответствиеТиповМоделиОписанийТипов()
	
	Карта = Новый Соответствие;
	Карта.Вставить(ТипыКолонок.Целое, Новый ОписаниеТипов("Число", Новый КвалификаторыЧисла(, 0)));
	Карта.Вставить(ТипыКолонок.Булево, Новый ОписаниеТипов("Булево"));
	Карта.Вставить(ТипыКолонок.Строка, Новый ОписаниеТипов("Строка"));
	Карта.Вставить(ТипыКолонок.Дата, Новый ОписаниеТипов("Дата", , , Новый КвалификаторыДаты(ЧастиДаты.Дата)));
	Карта.Вставить(ТипыКолонок.Время, Новый ОписаниеТипов("Дата", , , Новый КвалификаторыДаты(ЧастиДаты.Время)));
	Карта.Вставить(ТипыКолонок.ДатаВремя, Новый ОписаниеТипов("Дата", , , Новый КвалификаторыДаты(ЧастиДаты.ДатаВремя)));
	
	Возврат Карта;
	
КонецФункции