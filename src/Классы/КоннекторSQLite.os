#Использовать asserts
#Использовать logos
#Использовать reflector
#Использовать sql
#Использовать strings

Перем Соединение;

Перем Лог;

// Конструктор объекта КоннекторSQLite.
//
Процедура ПриСозданииОбъекта()
	Соединение = Новый Соединение();
	Лог = Логирование.ПолучитьЛог("oscript.lib.entity.connector.sqlite");
КонецПроцедуры

// Открыть соединение с БД.
//
// Параметры:
//   СтрокаСоединения - Строка - Строка соединения с БД.
//   ПараметрыКоннектора - Соответствие - Дополнительные параметры инициализиации коннектора.
//
Процедура Открыть(СтрокаСоединения, ПараметрыКоннектора) Экспорт
	Соединение.ТипСУБД = Соединение.ТипыСУБД.sqlite;
	Соединение.СтрокаСоединения = СтрокаСоединения;
	Соединение.Открыть();
КонецПроцедуры

// Закрыть соединение с БД.
//
Процедура Закрыть() Экспорт
	Соединение.Закрыть();
КонецПроцедуры

// Получить статус соединения с БД.
//
//  Возвращаемое значение:
//   Булево - Состояние соединения. Истина, если соединение установлено и готово к использованию.
//       В обратном случае - Ложь.
//
Функция Открыт() Экспорт
	Возврат Соединение.Открыто;
КонецФункции

// Начинает новую транзакцию в БД.
//
Процедура НачатьТранзакцию() Экспорт
	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	Запрос.Текст = "BEGIN TRANSACTION;";
	Запрос.ВыполнитьКоманду();
КонецПроцедуры

// Фиксирует открытую транзакцию в БД.
//
Процедура ЗафиксироватьТранзакцию() Экспорт
	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	Запрос.Текст = "COMMIT TRANSACTION;";
	Запрос.ВыполнитьКоманду();
КонецПроцедуры

// Отменяет открытую транзакцию в БД.
//
Процедура ОтменитьТранзакцию() Экспорт
	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	Запрос.Текст = "ROLLBACK TRANSACTION;";
	Запрос.ВыполнитьКоманду();
КонецПроцедуры

// Создает таблицу в БД по данным модели.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//
Процедура ИнициализироватьТаблицу(ОбъектМодели) Экспорт
	
	КартаТипов = СоответствиеТиповМоделиИТиповКолонок();

	ИмяТаблицы = ОбъектМодели.ИмяТаблицы();
		
	ТекстЗапроса = "CREATE TABLE IF NOT EXISTS %1 (
	|%2
	|);";
	КолонкиТаблицы = ОбъектМодели.Колонки();
	Идентификатор = ОбъектМодели.Идентификатор();
	СтрокаОпределенийКолонок = "";
	Для Каждого Колонка Из КолонкиТаблицы Цикл
		
		СтрокаКолонка = "";
		СтрокаПервичныйКлюч = "";

		// Формирование строки-колонки
		СтрокаКолонка = Символы.Таб + Колонка.ИмяКолонки;
		Если Колонка.ТипКолонки = ТипыКолонок.Ссылка Тогда
			ОбъектМоделиСсылка = ОбъектМодели.МодельДанных().Получить(Колонка.ТипСсылки);
			ТипКолонки = КартаТипов.Получить(ОбъектМоделиСсылка.Идентификатор().ТипКолонки);

			СтрокаПервичныйКлюч = Символы.Таб + СтрШаблон(
				"FOREIGN KEY (%1) REFERENCES %2(%3),%4",
				Колонка.ИмяКолонки,
				ОбъектМоделиСсылка.ИмяТаблицы(),
				ОбъектМоделиСсылка.Идентификатор().ИмяКолонки,
				Символы.ПС
			);
		Иначе
			ТипКолонки = КартаТипов.Получить(Колонка.ТипКолонки);
		КонецЕсли;
		СтрокаКолонка = СтрокаКолонка + " " + ТипКолонки;
		Если Колонка.ИмяПоля = Идентификатор.ИмяПоля Тогда
			СтрокаКолонка = СтрокаКолонка + " PRIMARY KEY";
		КонецЕсли;
		Если Колонка.ГенерируемоеЗначение Тогда
			СтрокаКолонка = СтрокаКолонка + " AUTOINCREMENT";
		КонецЕсли;
		СтрокаКолонка = СтрокаКолонка + "," + Символы.ПС;
		
		СтрокаОпределенийКолонок = СтрокаОпределенийКолонок + СтрокаКолонка;
		
		Если ЗначениеЗаполнено(СтрокаПервичныйКлюч) Тогда
			СтрокаОпределенийКолонок = СтрокаОпределенийКолонок + СтрокаПервичныйКлюч;
		КонецЕсли;
	КонецЦикла;
	СтроковыеФункции.УдалитьПоследнийСимволВСтроке(СтрокаОпределенийКолонок, 2);

	ТекстЗапроса = СтрШаблон(ТекстЗапроса, ИмяТаблицы, СтрокаОпределенийКолонок);
	Лог.Отладка("Инициализация таблицы %1:%2%3", ИмяТаблицы, Символы.ПС, ТекстЗапроса);

	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	Запрос.Текст = ТекстЗапроса;

	Запрос.ВыполнитьКоманду();
КонецПроцедуры

// Сохраняет сущность в БД.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//   Сущность - Произвольный - Объект (экземпляр класса, зарегистрированного в модели) для сохранения в БД.
//
Процедура Сохранить(ОбъектМодели, Сущность) Экспорт
	
	ИмяТаблицы = ОбъектМодели.ИмяТаблицы();
	КолонкиТаблицы = ОбъектМодели.Колонки();
	
	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	
	ИменаКолонок = "";
	ЗначенияКолонок = "";
	
	Если КолонкиТаблицы.Количество() = 1 И ОбъектМодели.Идентификатор().ГенерируемоеЗначение Тогда
		ИменаКолонок = Символы.Таб + ОбъектМодели.Идентификатор().ИмяКолонки;
		ЗначенияКолонок = Символы.Таб + "null"; 
	Иначе
		Для Каждого ДанныеОКолонке Из КолонкиТаблицы Цикл
			ЗначениеПараметра = ОбъектМодели.ПолучитьПриведенноеЗначениеПоля(Сущность, ДанныеОКолонке.ИмяПоля);
			
			Если ДанныеОКолонке.ГенерируемоеЗначение И НЕ ЗначениеЗаполнено(ЗначениеПараметра) Тогда
				// TODO: Поддержка чего-то кроме автоинкремента
				Продолжить;
			КонецЕсли;
			ИменаКолонок = ИменаКолонок + Символы.Таб + ДанныеОКолонке.ИмяКолонки + "," + Символы.ПС;
			ЗначенияКолонок = ЗначенияКолонок + Символы.Таб + "@" + ДанныеОКолонке.ИмяКолонки + "," + Символы.ПС;
			
			ЗначениеПараметра = ОбъектМодели.ПолучитьПриведенноеЗначениеПоля(Сущность, ДанныеОКолонке.ИмяПоля);
			Запрос.УстановитьПараметр(ДанныеОКолонке.ИмяКолонки, ЗначениеПараметра);
		КонецЦикла;

		СтроковыеФункции.УдалитьПоследнийСимволВСтроке(ИменаКолонок, 2);
		СтроковыеФункции.УдалитьПоследнийСимволВСтроке(ЗначенияКолонок, 2);
	КонецЕсли;
	
	ТекстЗапроса = "INSERT OR REPLACE INTO %1 (
	|%2
	|) VALUES (
	|%3
	|);";
	
	ТекстЗапроса = СтрШаблон(ТекстЗапроса, ИмяТаблицы, ИменаКолонок, ЗначенияКолонок);
	Лог.Отладка("Сохранение сущности с типом %1:%2%3", ОбъектМодели.ТипСущности(), Символы.ПС, ТекстЗапроса);	
	
	Запрос.Текст = ТекстЗапроса;
	Запрос.ВыполнитьКоманду();
	
	Если ОбъектМодели.Идентификатор().ГенерируемоеЗначение Тогда
		ИДПоследнейДобавленнойЗаписи = Запрос.ИДПоследнейДобавленнойЗаписи();
		ОбъектМодели.УстановитьЗначениеКолонкиВПоле(
			Сущность,
			ОбъектМодели.Идентификатор().ИмяКолонки,
			ИДПоследнейДобавленнойЗаписи
		);
	КонецЕсли;

	// TODO: Для полей с автоинкрементом - получить значения из базы.
	// по факту - просто переинициализировать класс значениями полей из СУБД.
	// ЗаполнитьСущность(Сущность, ОбъектМодели);

КонецПроцедуры

// Удаляет сущность из таблицы БД.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//   Сущность - Произвольный - Объект (экземпляр класса, зарегистрированного в модели) для удаления из БД.
//
Процедура Удалить(ОбъектМодели, Сущность) Экспорт
	
	ИмяТаблицы = ОбъектМодели.ИмяТаблицы();
	
	ТекстЗапроса = "DELETE FROM %1
	|WHERE %2 = @Идентификатор;";
	
	ТекстЗапроса = СтрШаблон(ТекстЗапроса, ИмяТаблицы, ОбъектМодели.Идентификатор().ИмяКолонки);
	Лог.Отладка(
		"Удаление сущности с типом %1 и идентификатором %2:%3%4",
		ОбъектМодели.ТипСущности(), 
		ОбъектМодели.ПолучитьЗначениеИдентификатора(Сущность),
		Символы.ПС, 
		ТекстЗапроса
	);	
	
	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("Идентификатор", ОбъектМодели.ПолучитьЗначениеИдентификатора(Сущность));
	Запрос.ВыполнитьКоманду();
	
КонецПроцедуры

// Осуществляет поиск строк в таблице по указанному отбору.
//
// Параметры:
//   ОбъектМодели - ОбъектМодели - Объект, содержащий описание класса-сущности и настроек таблицы БД.
//   Отбор - Массив - Отбор для поиска. Каждый элемент массива должен иметь тип "ЭлементОтбора".
//       Каждый элемент отбора преобразуется к условию поиска. В качестве "ПутьКДанным" указываются имена колонок.
//
//  Возвращаемое значение:
//   Массив - Массив, элементами которого являются "Соответствия". Ключом элемента соответствия является имя колонки,
//     значением элемента соответствия - значение колонки.
//
Функция НайтиСтрокиВТаблице(ОбъектМодели, Знач Отбор) Экспорт
	
	НайденныеСтроки = Новый Массив;
	Колонки = ОбъектМодели.Колонки();

	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	
	ТекстЗапроса = СтрШаблон(
		"SELECT * FROM %1", 
		ОбъектМодели.ИмяТаблицы()
	);
	
	СтрокаУсловий = "";
	
	Для сч = 0 По Отбор.ВГраница() Цикл
		ЭлементОтбора = Отбор[сч];
		ПредставлениеСчетчика = "п" + Формат(сч + 1, "ЧН=0; ЧГ=");
		Если ЗначениеЗаполнено(СтрокаУсловий) Тогда
			СтрокаУсловий = СтрокаУсловий + Символы.ПС + Символы.Таб + "AND ";
		КонецЕсли;
		СтрокаУсловий = СтрокаУсловий + СтрШаблон("%1 %2 @%3", ЭлементОтбора.ПутьКДанным, ЭлементОтбора.ВидСравнения, ПредставлениеСчетчика);
		Запрос.УстановитьПараметр(ПредставлениеСчетчика, ЭлементОтбора.Значение);
	КонецЦикла;
	
	Если ЗначениеЗаполнено(СтрокаУсловий) Тогда
		ТекстЗапроса = ТекстЗапроса + Символы.ПС + "WHERE " + СтрокаУсловий;
	КонецЕсли;

	Лог.Отладка("Поиск сущности в таблице %1:%2%3", ОбъектМодели.ИмяТаблицы(), Символы.ПС, ТекстЗапроса);

	Запрос.Текст = ТекстЗапроса;
	Результат = Запрос.Выполнить().Выгрузить();
	
	Если Результат.Количество() = 0 Тогда
		Лог.Отладка("Сущность с типом %1 не найдена", ОбъектМодели.ТипСущности());
		Возврат НайденныеСтроки;
	КонецЕсли;
	
	Для Каждого СтрокаИзБазы Из Результат Цикл
		ЗначенияКолонок = Новый Соответствие;

		Для Каждого Колонка Из Колонки Цикл
			ЗначениеКолонки = СтрокаИзБазы[Колонка.ИмяКолонки];
			ЗначенияКолонок.Вставить(Колонка.ИмяКолонки, ЗначениеКолонки);
		КонецЦикла;

		НайденныеСтроки.Добавить(ЗначенияКолонок);
	КонецЦикла;
	
	Возврат НайденныеСтроки;

КонецФункции

// @Unstable
// Выполнить произвольный запрос и получить результат.
//
// Данный метод не входит в основной интерфейс "Коннектор".
// Не рекомендуется использовать этот метод в прикладном коде, сигнатура метода может измениться.
//
// Параметры:
//   ТекстЗапроса - Строка - Текст выполняемого запроса
//
//  Возвращаемое значение:
//   ТаблицаЗначений - Результат выполнения запроса.
//
Функция ВыполнитьЗапрос(ТекстЗапроса) Экспорт
	
	// TODO: Стоит вынести в сам менеджер?
	Запрос = Новый Запрос();
	Запрос.УстановитьСоединение(Соединение);
	Запрос.Текст = ТекстЗапроса;
	Результат = Запрос.Выполнить().Выгрузить();
	
	Возврат Результат;

КонецФункции

Функция СоответствиеТиповМоделиИТиповКолонок()
	
	Карта = Новый Соответствие;
	Карта.Вставить(ТипыКолонок.Целое, "INTEGER");
	Карта.Вставить(ТипыКолонок.Дробное, "DECIMAL");
	Карта.Вставить(ТипыКолонок.Булево, "BOOLEAN");
	Карта.Вставить(ТипыКолонок.Строка, "TEXT");
	Карта.Вставить(ТипыКолонок.Дата, "DATE");
	Карта.Вставить(ТипыКолонок.Время, "TIME");
	Карта.Вставить(ТипыКолонок.ДатаВремя, "DATETIME");
	
	Возврат Карта;
	
КонецФункции
