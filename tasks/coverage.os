#Использовать 1commands
#Использовать fs
#Использовать coverage

СистемнаяИнформация = Новый СистемнаяИнформация;
ЭтоWindows = Найти(НРег(СистемнаяИнформация.ВерсияОС), "windows") > 0;

ФС.ОбеспечитьПустойКаталог("coverage");
ПутьКСтат = "coverage/stat.json";

Команда = Новый Команда;
Команда.УстановитьКоманду("oscript");
Если НЕ ЭтоWindows Тогда
	Команда.ДобавитьПараметр("-encoding=utf-8");
КонецЕсли;
Команда.ДобавитьПараметр(СтрШаблон("-codestat=%1", ПутьКСтат));
Команда.ДобавитьПараметр("tasks/test.os"); // Файла запуска тестов
Команда.ПоказыватьВыводНемедленно(Истина);

КодВозврата = Команда.Исполнить();

Файл_Стат = Новый Файл(ПутьКСтат);

ИмяПакета = "oscript-package";

ПроцессорГенерации = Новый ГенераторОтчетаПокрытия();

ПроцессорГенерации.ОтносительныеПути()
				.ФайлСтатистики(Файл_Стат.ПолноеИмя)
				.Cobertura() // Формирование отчета в формате Cobertura
				.Сформировать();

ЗавершитьРаботу(КодВозврата);