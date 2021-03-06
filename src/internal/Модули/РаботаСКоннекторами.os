#Использовать asserts

Перем СвойстваКоннекторов;

Функция СоздатьКоннектор(ТипКоннектора) Экспорт
	Коннектор = Новый(ТипКоннектора);
	СвойстваКоннектора = Конструктор_СвойстваКоннектора();
	СвойстваКоннекторов.Вставить(Коннектор, СвойстваКоннектора);

	Возврат Коннектор;
КонецФункции

Процедура ОткрытьКоннектор(Коннектор, СтрокаСоединения, ПараметрыКоннектора) Экспорт
	СвойстваКоннектора = СвойстваКоннекторов.Получить(Коннектор);
	СвойстваКоннектора.СтрокаСоединения = СтрокаСоединения;
	СвойстваКоннектора.Параметры = ПараметрыКоннектора;

	Коннектор.Открыть(СтрокаСоединения, ПараметрыКоннектора);
КонецПроцедуры

Процедура ЗакрытьКоннектор(Коннектор) Экспорт
	Если Коннектор.Открыт() Тогда
		Коннектор.Закрыть();
	КонецЕсли;
КонецПроцедуры

Функция Сохранить(Коннектор, ОбъектМодели, ПулСущностей, Сущность) Экспорт
	ТипСущности = ТипЗнч(Сущность);
	
	ПроверитьЧтоКлассЯвляетсяСущностью(ТипСущности);
	ПроверитьЧтоТипСущностиЗарегистрированВМодели(ОбъектМодели);
	ПроверитьНеобходимостьЗаполненияИдентификатора(ОбъектМодели, Сущность);
	
	Коннектор.Сохранить(ОбъектМодели, Сущность);
	
	ПулСущностей.Вставить(ОбъектМодели.ПолучитьЗначениеИдентификатора(Сущность), Сущность);
КонецФункции

Функция Получить(Коннектор, ОбъектМодели, ПулСущностей, Отбор = Неопределено) Экспорт
	Колонки = ОбъектМодели.Колонки();
	
	ПередаваемыйОтбор = Новый Массив;
	
	Если ТипЗнч(Отбор) = Тип("Соответствие") Тогда
		// Переформируем ключи отбора из имен полей в имена колонок
		Для Каждого КлючИЗначение Из Отбор Цикл
			Колонка = Колонки.Найти(КлючИЗначение.Ключ, "ИмяПоля");
				Ожидаем.Что(
				Колонка, 
				СтрШаблон("Не удалось найти данные о колонке по имени поля %1", КлючИЗначение.Ключ)
			).Не_().Равно(Неопределено);
			
			ПередаваемыйОтбор.Добавить(Новый ЭлементОтбора(Колонка.ИмяКолонки, ВидСравнения.Равно, КлючИЗначение.Значение));
		КонецЦикла;
	ИначеЕсли ТипЗнч(Отбор) = Тип("Массив") Тогда
		Для Каждого ЭлементОтбора Из Отбор Цикл
			Колонка = Колонки.Найти(ЭлементОтбора.ПутьКДанным, "ИмяПоля");
				Ожидаем.Что(
				Колонка, 
				СтрШаблон("Не удалось найти данные о колонке по имени поля %1", ЭлементОтбора.ПутьКДанным)
			).Не_().Равно(Неопределено);
			
			ПередаваемыйОтбор.Добавить(Новый ЭлементОтбора(Колонка.ИмяКолонки, ЭлементОтбора.ВидСравнения, ЭлементОтбора.Значение));
		КонецЦикла;
	ИначеЕсли ТипЗнч(Отбор) = Тип("ЭлементОтбора") Тогда
		ЭлементОтбора = Отбор;
			Колонка = Колонки.Найти(ЭлементОтбора.ПутьКДанным, "ИмяПоля");
			Ожидаем.Что(
			Колонка, 
			СтрШаблон("Не удалось найти данные о колонке по имени поля %1", ЭлементОтбора.ПутьКДанным)
		).Не_().Равно(Неопределено);

		ПередаваемыйОтбор.Добавить(Новый ЭлементОтбора(Колонка.ИмяКолонки, ЭлементОтбора.ВидСравнения, ЭлементОтбора.Значение));
	ИначеЕсли Отбор = Неопределено Тогда
		// no-op
	Иначе
		ВызватьИсключение "В метод получения данных передан неожиданный тип отбора: " + ТипЗнч(Отбор);
	КонецЕсли;

	НайденныеСущности = Новый Массив;

	НайденныеСтроки = Коннектор.НайтиСтрокиВТаблице(ОбъектМодели, ПередаваемыйОтбор);
	Если НайденныеСтроки.Количество() = 0 Тогда
		Возврат НайденныеСущности;
	КонецЕсли;

	Для Каждого НайденнаяСтрока Из НайденныеСтроки Цикл
		ЗначениеИдентификатора = НайденнаяСтрока.Получить(ОбъектМодели.Идентификатор().ИмяКолонки);
		ЗначениеИдентификатора = ОбъектМодели.ПривестиЗначениеПоля(
			ЗначениеИдентификатора,
			ОбъектМодели.Идентификатор().ИмяПоля
		);
		Сущность = ПулСущностей.Получить(ЗначениеИдентификатора);
		Если Сущность = Неопределено Тогда
			Сущность = Новый(ОбъектМодели.ТипСущности());
			ПулСущностей.Вставить(ЗначениеИдентификатора, Сущность);
		КонецЕсли;

		Для Каждого Колонка Из Колонки Цикл
			ЗначениеКолонки = НайденнаяСтрока.Получить(Колонка.ИмяКолонки);
			Если Колонка.ТипКолонки = ТипыКолонок.Ссылка И ЗначениеЗаполнено(ЗначениеКолонки) Тогда
				
				Если Колонка.ТипСсылки = ОбъектМодели.ТипСущности() И ЗначениеКолонки = ЗначениеИдентификатора Тогда
					ЗначениеКолонки = Сущность;
				Иначе
					ХранилищеСущностейСсылки = ХранилищаСущностей.Получить(
						ОбъектМодели.МодельДанных().Получить(Колонка.ТипСсылки),
						Коннектор
					);
					ЗначениеКолонки = ХранилищеСущностейСсылки.ПолучитьОдно(ЗначениеКолонки);
				КонецЕсли;
			КонецЕсли;
			ОбъектМодели.УстановитьЗначениеКолонкиВПоле(Сущность, Колонка.ИмяКолонки, ЗначениеКолонки);
		КонецЦикла;
		
		НайденныеСущности.Добавить(Сущность);
	КонецЦикла;

	Возврат НайденныеСущности;
КонецФункции

Функция ПолучитьОдно(Коннектор, ОбъектМодели, ПулСущностей, Знач Отбор = Неопределено) Экспорт
	
	Если Отбор = Неопределено Тогда
		ПередаваемыйОтбор = Отбор;
	ИначеЕсли ТипЗнч(Отбор) = Тип("Соответствие") Тогда
		ПередаваемыйОтбор = Отбор;
	ИначеЕсли ТипЗнч(Отбор) = Тип("Массив") Тогда
		ПередаваемыйОтбор = Отбор;
	ИначеЕсли ТипЗнч(Отбор) = Тип("ЭлементОтбора") Тогда
		ПередаваемыйОтбор = Отбор;
	Иначе
		ПередаваемыйОтбор = Новый Соответствие();
		ПередаваемыйОтбор.Вставить(ОбъектМодели.Идентификатор().ИмяПоля, Отбор);
	КонецЕсли;
	
	НайденныеСущности = Получить(Коннектор, ОбъектМодели, ПулСущностей, ПередаваемыйОтбор);
	
	Если НайденныеСущности.Количество() = 0 Тогда
		Возврат Неопределено;
	Иначе
		Возврат НайденныеСущности[0];
	КонецЕсли;
	
КонецФункции

// Удаляет удаление сущности из базы данных.
// Сущность должна иметь заполненный идентификатор.
//
// Параметры:
//   Сущность - Произвольный - Удаляемая сущность
//
Процедура Удалить(Коннектор, ОбъектМодели, ПулСущностей, Сущность) Экспорт
	Коннектор.Удалить(ОбъектМодели, Сущность);
	ПулСущностей.Удалить(Сущность);
КонецПроцедуры

// Посылает коннектору запрос на начало транзакции.
//
Процедура НачатьТранзакцию(Коннектор) Экспорт
	Коннектор.НачатьТранзакцию();
КонецПроцедуры

// Посылает коннектору запрос на фиксацию транзакции.
//
Процедура ЗафиксироватьТранзакцию(Коннектор) Экспорт
	Коннектор.ЗафиксироватьТранзакцию();
КонецПроцедуры

// Посылает коннектору запрос на отмену транзакции.
//
Процедура ОтменитьТранзакцию(Коннектор) Экспорт
	Коннектор.ОтменитьТранзакцию();
КонецПроцедуры

// Возвращает дополнительные свойства коннектора
//
// Параметры:
//   Коннектор - АбстрактныйКоннектор - Коннектор, свойства которого необходимо получить.
//
//  Возвращаемое значение:
//   Структура - Дополнительные свойства коннектора. см. Конструктор_СвойстваКоннектора()
//
Функция ПолучитьСвойстваКоннектора(Коннектор) Экспорт
	Возврат СвойстваКоннекторов.Получить(Коннектор);
КонецФункции

// <Описание процедуры>
//
// Параметры:
//   ТипКласса - Тип - Тип, в котором проверяется наличие необходимых аннотаций.
//
Процедура ПроверитьЧтоКлассЯвляетсяСущностью(ТипКласса)
	
	РефлекторОбъекта = Новый РефлекторОбъекта(ТипКласса);
	ТаблицаМетодов = РефлекторОбъекта.ПолучитьТаблицуМетодов("Сущность", Ложь);
	Ожидаем.Что(ТаблицаМетодов, СтрШаблон("Класс %1 не имеет аннотации &Сущность", ТипКласса)).ИмеетДлину(1);
	
	ТаблицаСвойств = РефлекторОбъекта.ПолучитьТаблицуСвойств("Идентификатор");
	Ожидаем.Что(ТаблицаСвойств, СтрШаблон("Класс %1 не имеет поля с аннотацией &Идентификатор", ТипКласса)).ИмеетДлину(1);
	
КонецПроцедуры

Процедура ПроверитьЧтоТипСущностиЗарегистрированВМодели(ОбъектМодели)
	// TODO: проверка должна быть в момент получения репозитория
	Ожидаем.Что(ОбъектМодели, "Тип сущности не зарегистрирован в модели данных").Не_().Равно(Неопределено);
КонецПроцедуры

Процедура ПроверитьНеобходимостьЗаполненияИдентификатора(ОбъектМодели, Сущность)
	Если ОбъектМодели.Идентификатор().ГенерируемоеЗначение Тогда
		Возврат;
	КонецЕсли;
	
	ЗначениеИдентификатора = ОбъектМодели.ПолучитьЗначениеИдентификатора(Сущность);
		Ожидаем.Что(
		ЗначениеИдентификатора, СтрШаблон("Сущность с типом %1 должна иметь заполненный идентификатор", Тип(Сущность))
	).Заполнено();

КонецПроцедуры

Функция Конструктор_СвойстваКоннектора()
	СвойстваКоннектора = Новый Структура;
	СвойстваКоннектора.Вставить("СтрокаСоединения");
	СвойстваКоннектора.Вставить("Параметры");
	
	Возврат СвойстваКоннектора;
КонецФункции

СвойстваКоннекторов = Новый Соответствие();
