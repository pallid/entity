Перем ВнутреннийИдентификатор Экспорт;

Перем Имя Экспорт;
Перем ВтороеИмя Экспорт;

&Сущность(ИмяТаблицы = "Авторы")
&Идентификатор(ИмяРеквизита = "ВнутреннийИдентификатор")
&ГенерируемоеЗначение
&Колонка(ИмяРеквизита = "ВнутреннийИдентификатор", ТипКолонки = "Целое")
&Колонка(ИмяРеквизита = "ВтороеИмя", Имя = "Фамилия")
Процедура ПриСозданииОбъекта() Экспорт

КонецПроцедуры
