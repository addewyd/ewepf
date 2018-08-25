&AtServer
var tables6;

#Область ОбработчикиКомандФормы

&НаКлиенте
procedure OpenFile(command)
	
	ДиалогФыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогФыбораФайла.Фильтр = "XML (*.xml)|*.xml";
	ДиалогФыбораФайла.Заголовок = "Выберите файл";                                         
	ДиалогФыбораФайла.ПредварительныйПросмотр = false;
	ДиалогФыбораФайла.ИндексФильтра = 0;
	Если ДиалогФыбораФайла.Выбрать() Тогда
   		// Действия, выполняемые тогда, когда файл выбран.
		ПолноеИмяФайла = ДиалогФыбораФайла.ПолноеИмяФайла;
		stage = 1;
		message("stage 1");
		//ReadFile.Доступность = true;

	КонецЕсли;	
	
endProcedure

&НаСервере
Процедура ПриОткрытииНаСервере()
	// Вставить содержимое обработчика.
	//Message("SOpen");
	Message("stage " + stage);
	RestoreOptions();
	//ReadOrdersButton.Доступность = false;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	// Вставить содержимое обработчика.
	//Message("Start");
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Stage = 0;
	message("stage 0");
	ПриОткрытииНаСервере();
	СоздатьТаблицы();
	
//	Сообщить(мТехПрокачка, СтатусСообщения.Внимание);	
	
КонецПроцедуры

&НаКлиенте
Procedure ReadFile(command)
	XMLString = "";
	
	if TrimAll(ПолноеИмяФайла) <> "" then
		stage = 1;
		message("stage 1");
	endif;
	
	//ReadOrdersButton.Доступность = false;
	
	if stage < 1 then
		Message("DataPaket does not chosen");
		return;
	endif;
	
	Текст = Новый ЧтениеТекста(ПолноеИмяФайла);
	while true do
        Строка = Текст.ПрочитатьСтроку();
        Если Строка = Неопределено Тогда
            Прервать;
		Иначе
			XmlString = XmlString + Строка;
			
        КонецЕсли;
	enddo;
	Stage = 2;
	message("stage 2");	
	ЧитатьДанныеСессии(XMLString, ПолноеИмяФайла);
	//ReadOrdersButton.Доступность = true;

EndProcedure	

&НаКлиенте
Procedure ReadOrders(command)
	
	fname = ПолучитьИмяФайла(ПолноеИмяФайла);
	dir = СтрЗаменить(ПолноеИмяФайла, fname, "");
	xmlstrings = new array;
	
	Files = FindFiles(dir, "order_*.xml", false);
	
	Message("Files found: " + Files.Count());
	OrderList = new Array;
	For Each fo in files do
		f = fo.name;
		FDate = Date(Number(Mid(f,7,4)),
			Number(Mid(f,12,2)),Number(Mid(f,15,2))); 
			
			For Each dt in DateList do
			dt10 = date10(dt);	
			dt2 = dt10 + 24*60*60 * 2;
			if (dt10 <= fdate) and (fdate <= dt2) then
				if orderlist.find(fo.FullName) = Undefined then
					OrderList.Add(fo.FullName);
				endif;
			endif;
			
		enddo;

	enddo;
	
	Message("Orders found: " + OrderList.Count());
	
	for each f in orderlist do
		xmlstring = "";
		Текст = Новый ЧтениеТекста(f);
		Пока Истина Цикл
        	Строка = Текст.ПрочитатьСтроку();
        	Если Строка = Неопределено Тогда
            	Прервать;
			Иначе
				XmlString = XmlString + Строка;
        	КонецЕсли;
		КонецЦикла;
		xmlstrings.add(xmlstring);
	enddo;
		
	ReadOrdersServer(xmlstrings);
EndProcedure	

&НаКлиенте
Procedure CreateDocsCl(command)
	ref = CreateDocs();
	//ShowValue(,ref);
EndProcedure	

#КонецОбласти

&НаСервере
Procedure SaveOptions()
	ObjKey = "topaz";
	OptKey = "topaz";
	owner = ИмяПользователя();
	opts = new map;
	
	//opts.insert("XMLFileName", ПолноеИмяФайла);
	
	//ХранилищеОбщихНастроек.Cохранить(ObjKey, OptKey, opts,,Owner);
	
endprocedure

&НаСервере
Procedure RestoreOptions()
	ObjKey = "topaz";
	OptKey = "topaz";
	owner = ИмяПользователя();
	
	opts = undefined;
	
	try
		//opts = ХранилищеОбщихНастроек.Загрузить(ObjKey, OptKey,,Owner);
	except
		message("restore options failed");
		return;
	endtry;
	
	if opts <> Undefined then
		//ПолноеИмяФайла = opts["XMLFileName"];
	endif;
	
endprocedure

&НаСервере
Процедура СоздатьТаблицы()
	
	S = Новый ОписаниеТипов("Строка");
	D = Новый ОписаниеТипов("Число",
        Новый КвалификаторыЧисла(15, 2));
			
// ..............................................................................	

	m = РеквизитФормыВЗначение("мТехПрокачка");
	m.Колонки.Добавить("Index", S, "1");
	m.Колонки.Добавить("Объём", D, "2");

	НовыеРеквизиты = Новый Массив;
 
    Для Каждого Колонка Из m.Колонки Цикл
         НовыеРеквизиты.Добавить(
            Новый РеквизитФормы(
                Колонка.Имя, Колонка.ТипЗначения,
                "мТехПрокачка"
            )
         );
	КонецЦикла;	
		 
	ИзменитьРеквизиты(НовыеРеквизиты);
	 
		 
//	Для Каждого Колонка Из m.Колонки Цикл
//        НовыйЭлемент = Элементы.Добавить(
//            "" + m + "_" + Колонка.Имя, Тип("ПолеФормы"), Элементы["мТехПрокачка1"]
//        );
//        НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
//        НовыйЭлемент.ПутьКДанным = "мТехПрокачка" + "." + Колонка.Имя;
//    КонецЦикла;

	ЗначениеВРеквизитФормы(m, "мТехПрокачка");
	
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьИмяФайла(Знач ПолноеИмя)
	Поз=Найти(ПолноеИмя,"\");
	Пока Поз>0 Цикл 
		ПолноеИмя=Сред(ПолноеИмя,Поз+1); 
		Поз=Найти(ПолноеИмя,"\");
	КонецЦикла;
	Возврат ПолноеИмя;
КонецФункции  

&НаКлиентеНаСервереБезКонтекста
function stonum(s)
	ret = 0;
	a = СтрЗаменить(s," ","");
	try
		ret = Число(СтрЗаменить(a,",","."));
		//message("normal, s=|" + s + "|" + a + "|");
	except
		//message("Exception, s=|" + s + "|" + a + "|");
		ret = s;
	endtry;
	return ret;
	
endfunction

&НаКлиентеНаСервереБезКонтекста
Функция ЭтоЧисло(Знач ТекСтр)  
// Excellent!!!
    ТекСтр=СокрЛП(ТекСтр);
	Если ТекСтр="" Тогда   
		Возврат 0;
	КонецЕсли;    
	Если ТекСтр="." Тогда   
		Возврат 0;
	КонецЕсли;    
	Если ТекСтр="," Тогда   
		Возврат 0;
	КонецЕсли;    
	ТекСтр=СтрЗаменить(ТекСтр,"0",""); 
	ТекСтр=СтрЗаменить(ТекСтр,"1","");
	ТекСтр=СтрЗаменить(ТекСтр,"2","");
	ТекСтр=СтрЗаменить(ТекСтр,"3","");
	ТекСтр=СтрЗаменить(ТекСтр,"4","");
	ТекСтр=СтрЗаменить(ТекСтр,"5","");
	ТекСтр=СтрЗаменить(ТекСтр,"6","");
	ТекСтр=СтрЗаменить(ТекСтр,"7","");
	ТекСтр=СтрЗаменить(ТекСтр,"8","");
	ТекСтр=СтрЗаменить(ТекСтр,"9","");     
	Если ТекСтр="" Тогда   
		Возврат 1;
	КонецЕсли;   
	Если ТекСтр="." Тогда   
		Возврат 1;
	КонецЕсли;   
	Если ТекСтр="," Тогда   
		Возврат 1;
	КонецЕсли;  
	Возврат 0;
	
КонецФункции     

&НаКлиентеНаСервереБезКонтекста
Функция date10(стрДата)// экспорт // "01.12.2011" преобразует в '01.12.2011 0:00:00' 
Попытка 
возврат Дата(Сред(стрДата,7,4)+Сред(стрДата,4,2)+Лев(стрДата,2)) 
Исключение 
возврат '00010101' 
КонецПопытки; 
КонецФункции // ДатаИзСтроки10()

&НаСервере
procedure ChangeRequisites(table, tablename)
	
	v = FormAttributeToValue(tablename);
	if v.columns.Count() > 0 then
		return;
	Endif;
	
	NewReqs = New array;
			
		for each col in table.columns do
    	    NewReqs.Add(
            	New РеквизитФормы(
                	Col.Name, Col.ТипЗначения,
                	tablename
            	)
         	);
		enddo;	
		ИзменитьРеквизиты(NewReqs);

		Для Каждого Колонка Из table.Колонки Цикл
			Колонка.Заголовок = Колонка.Имя + "HEAD";      // ?
        	НовыйЭлемент = Элементы.Добавить(
            	"" + tablename + "_" + Колонка.Имя, Тип("ПолеФормы"), Элементы[tablename]
        	);
        	НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
        	НовыйЭлемент.ПутьКДанным = tablename + "." + Колонка.Имя;
		КонецЦикла;
	
endProcedure	


&НаСервере
Procedure ReadOrdersServer(XMLStrings)
	
	// Lab016
	
	Message("stage " + stage);
	if stage < 3 then
		Message("DataPaket does not loaded");
		return;
	endif;
	
	message("strings count: " + xmlstrings.count());
	
	Парсер = Новый ЧтениеXML;
	tablename = "OutcomesByOffice";
	
	table = FormAttributeToValue(tablename);
	for i = 0 to table.count() - 1 do
		str = table.get(i);
		pos = find(str.Time, ":");
		if pos = 2 then
			str.time = "0" + str.Time;
		endif;
		//str.HasOrder = 1;
		for each xml in XMLStrings do
			Парсер.УстановитьСтроку(xml); 
    		Построитель = Новый ПостроительDOM;
    		Док = Построитель.Прочитать(Парсер);
			
			OrderData = Док.FirstChild;
			Если (OrderData.NodeName = "OrderData") Тогда
				eldate = OrderData.GetElementByTagName("Date")[0];
				date_ = eldate.TextContent;
				Date_=Прав(Date_,2)+"."+Сред(Date_,4,2)+".20"+Лев(Date_,2);
				eltime = OrderData.GetElementByTagName("Time")[0];
				Time = eltime.TextContent;
				FuelExtCode = OrderData.GetElementByTagName("FuelExCode")[0].TextContent;
				TankNum = OrderData.GetElementByTagName("TanksNum")[0].TextContent;
				if(str.Date = date_) and (str.Time = time) 
					and (str.FuelExtCode=FuelExtCode) and (str.TankNum=TankNum) then
					str.OrigPrice = OrderData.GetElementByTagName("FuelPrice")[0].TextContent;
					str.Volume = OrderData.GetElementByTagName("FuelVolume")[0].TextContent;
					str.Amount = OrderData.GetElementByTagName("FuelAmount")[0].TextContent;
					str.HasOrder = "1";
				endif;
						
			endif;
		enddo;
	enddo;
	
	for i = 0 to table.count() - 1 do
		
		str = table.get(i);
		if str.HasOrder = 0 then
			k = Справочники.Контрагенты.НайтиПоКоду(str.PartnerExtCode);
			kn = "<not found>";
			if not k = Undefined then
				kn = k.Наименование;
			endif;
			Message("Операция " + str.Date + " " + str.Time
				+ ": не найден Order: код клиента "
				+ str.PartnerExtCode + ", клиент  " + kn 
				+ " .   Цена, Объем, Сумма получены из файла Session.");
		endif;
	enddo;	
	
	ValueToFormAttribute(table, tablename);
	
	table.GroupBy("TankNum,OrigPrice,PaymentModeExtCode,FuelExtCode,"+
					"PaymentModeName,FuelName,PartnerExtCode,КодАЗС,"+
					"НомерСмены,НачалоСмены,КонецСмены,ОператорСмены,ФайлЗагрузки",
		"Mass,Volume,Amount");
	tablename = tablename + "GB";
	ChangeRequisites(table, tablename);
	ValueToFormAttribute(table, tablename);
	
	ContinueReadSessionData();
	
EndProcedure	

&НаСервере
Procedure ClearTables()
	
	for each tn in tables6 do
	
		table = FormAttributeToValue(tn);
		table.clear();
		ValueToFormAttribute(table, tn);
	enddo;
	
EndProcedure

&НаСервере
Функция ПолучитьПлотностьГСМ(КодАЗС,НомерСмены,Знач TankNum)  
	фПлотность = FormAttributeToValue("Dens");
	TankNum=Число(СокрЛП(TankNum));
	Индекс=ЗначениеВСтрокуВнутр(КодАЗС)
		+ЗначениеВСтрокуВнутр(НомерСмены)
		+ЗначениеВСтрокуВнутр(TankNum);
		
	Плотность=0;
	
//	Если фПлотность.НайтиЗначение(Индекс,Стр,"Индекс")=1 Тогда
//		Плотность=фПлотность.ПолучитьЗначение(Стр,"Плотность"); // плотность в т/м3
//	КонецЕсли;	
//	Если Плотность=0 Тогда      
//		Если ВвестиЧисло(Плотность,"Ввести плотность TankNum "+TankNum+" (тонн/м3)",10,5)=1 Тогда  
//			Если Плотность<>0 Тогда  
//				Если Стр=0 Тогда
//					фПлотность.НоваяСтрока();   
//					фПлотность.TankNum=TankNum;
//					фПлотность.Индекс=Индекс;     
//					Стр=фПлотность.КоличествоСтрок();
//				КонецЕсли;	
//				фПлотность.УстановитьЗначение(Стр,"Плотность",Плотность); 
//				фПлотность.Сортировать("TankNum");
//			КонецЕсли;
//		КонецЕсли;   
//	КонецЕсли;   
	str = фПлотность.Find(Индекс, "Индекс");
	
	if not (str = Undefined) then
		Плотность = str.Density;
	endif;
	
	Возврат Плотность;
КонецФункции     

&НаСервере
procedure szadd(m, v, k)
	m.insert(k, v);
endprocedure

&НаСервере
Функция ПолучитьФормуОплаты(КодОплаты,НаименованиеОплаты)  
	
	СЗ=new map;
	Если КодОплаты="01ВД00" Тогда
		szadd(СЗ,"07.Ведомость","ДляТаблицы");
		szadd(СЗ,"Ведомость","ДляДокумента");
	ИначеЕсли КодОплаты="01БС00" Тогда
		szadd(СЗ,"01.Банк Мир","ДляТаблицы");
		szadd(СЗ,"Банк","ДляДокумента");
	ИначеЕсли КодОплаты="01БС01" Тогда
		szadd(СЗ,"02.Банк Visa","ДляТаблицы");
		szadd(СЗ,"Банк","ДляДокумента");
	ИначеЕсли КодОплаты="01БС02" Тогда
		szadd(СЗ,"03.Банк Mastercard","ДляТаблицы");
		szadd(СЗ,"Банк","ДляДокумента");
	ИначеЕсли КодОплаты="01ОК00" Тогда
		szadd(СЗ,"08.Корпоративные карты","ДляТаблицы");
		szadd(СЗ,"Корпоративные карты","ДляДокумента");
	ИначеЕсли КодОплаты="02БС00" Тогда
		szadd(СЗ,"04.Наличные","ДляТаблицы");
		szadd(СЗ,"Наличные","ДляДокумента");
	ИначеЕсли КодОплаты="02СК00" Тогда
		szadd(СЗ,"05.Наличные скидка","ДляТаблицы");
		szadd(СЗ,"Наличные","ДляДокумента");
	ИначеЕсли КодОплаты="02СК01" Тогда
		szadd(СЗ,"06.Наличные скидка свыше 80 л","ДляТаблицы");
		szadd(СЗ,"Наличные","ДляДокумента");
	ИначеЕсли КодОплаты="02ОС00" Тогда
		szadd(СЗ,"09.Дисконтные карты","ДляТаблицы");
		szadd(СЗ,"Дисконтные карты","ДляДокумента");
	ИначеЕсли КодОплаты="01ТК00" Тогда
		szadd(СЗ,"10.Топливные карты","ДляТаблицы");
		szadd(СЗ,"Топливные карты","ДляДокумента");
	ИначеЕсли КодОплаты="01ТЛ00" Тогда
		szadd(СЗ,"11.Талоны","ДляТаблицы");
		szadd(СЗ,"Талоны","ДляДокумента");
	ИначеЕсли КодОплаты="01ТП00" Тогда
		szadd(СЗ,"12.ТехПрокачка","ДляТаблицы");
		szadd(СЗ,"","ДляДокумента");
	ИначеЕсли КодОплаты="01ВД0Т" Тогда
		szadd(СЗ,"07.Ведомость","ДляТаблицы");
		szadd(СЗ,"Ведомость","ДляДокумента");
	ИначеЕсли КодОплаты="01БСТ0" Тогда
		szadd(СЗ,"01.Банк Мир","ДляТаблицы");
		szadd(СЗ,"Банк","ДляДокумента");
	ИначеЕсли КодОплаты="01БСТ1" Тогда
		szadd(СЗ,"02.Банк Visa","ДляТаблицы");
		szadd(СЗ,"Банк","ДляДокумента");
	ИначеЕсли КодОплаты="01БСТ2" Тогда
		szadd(СЗ,"03.Банк Mastercard","ДляТаблицы");
		szadd(СЗ,"Банк","ДляДокумента");
	ИначеЕсли КодОплаты="01ОК0Т" Тогда
		szadd(СЗ,"08.Корпоративные карты","ДляТаблицы");
		szadd(СЗ,"Корпоративные карты","ДляДокумента");
	ИначеЕсли КодОплаты="02БСТ0" Тогда
		szadd(СЗ,"04.Наличные","ДляТаблицы");
		szadd(СЗ,"Наличные","ДляДокумента");
	ИначеЕсли КодОплаты="02БСТ1" Тогда
		szadd(СЗ,"05.Наличные скидка","ДляТаблицы");
		szadd(СЗ,"Наличные","ДляДокумента");
	ИначеЕсли КодОплаты="02ОС0Т" Тогда
		szadd(СЗ,"09.Дисконтные карты","ДляТаблицы");
		szadd(СЗ,"Дисконтные карты","ДляДокумента");
	ИначеЕсли КодОплаты="01ТК0Т" Тогда
		szadd(СЗ,"10.Топливные карты","ДляТаблицы");
		szadd(СЗ,"Топливные карты","ДляДокумента");  
	ИначеЕсли НаименованиеОплаты="Безналичный расчет" Тогда
		szadd(СЗ,"13.Переливы","ДляТаблицы");
		szadd(СЗ,"Переливы","ДляДокумента"); 
	Иначе
		szadd(СЗ,НаименованиеОплаты,"ДляТаблицы");
		szadd(СЗ,НаименованиеОплаты,"ДляДокумента");	
	КонецЕсли;	
    Возврат СЗ

КонецФункции


&НаСервере
Функция РасчетНДС(Товар,Сумма,ВыбДата,ss, ЧтениеИзФайла)
	
	// TODO
	// СтавкаНДС выбирать из перечисления!
	CatNDS = Перечисления.СтавкиНДС;
	//nds = CatNDS.EmptyRef();
	
	Если ЧтениеИзФайла Тогда
		Если ss = "" Тогда
			Если false then // ТекВариантРасчетаНалогов.УчитыватьНДС Тогда                          
				//Если ТекВариантРасчетаНалогов.СтавкаНДСИзНоменклатуры Тогда
				//	СтавкаНДС = Товар.СтавкаНДС.Получить(ВыбДата); // лажа в товарах
				//Иначе                          
				//	СтавкаНДС = ТекВариантРасчетаНалогов.СтавкаНДС;
				//КонецЕсли;   
			Иначе
				// СтавкаНДС = ПолучитьПустоеЗначение("Справочник.СтавкиНДС");  
			КонецЕсли;             
		Иначе
			// ХРЕНЬ КАКАЯ-ТО
			//СпрСтавкиНДС =СоздатьОбъект("Справочник.СтавкиНДС");
			//Если СпрСтавкиНДС.НайтиПоРеквизиту("Ставка",СтавкаНДС,1)=1 Тогда
			//	СтавкаНДС=СпрСтавкиНДС.ТекущийЭлемент();
			//Иначе
			//	СтавкаНДС = ПолучитьПустоеЗначение("Справочник.СтавкиНДС");  
			//КонецЕсли;	
			
			//    nds = CatNDS.НайтиПоРеквизиту("Ставка", ss);
			nds = null;
			
			// !!!
		КонецЕсли;                
	КонецЕсли;
	snds = 18.0;
	СтавкаНДС = snds;
	//Если ТекВариантРасчетаНалогов.СуммаВключаетНДС = 1 Тогда
	//		СуммаНДС = Сумма-Окр(Сумма/(1 + nds.Ставка / 100),2);  
		СуммаНДС = Сумма - Окр(Сумма/(1 + snds / 100),2);  
		СуммаВсего = Сумма;
	
	//Иначе
	//	СуммаНДС=Окр(Сумма*nds.Ставка/100,2); 
	//	СуммаВсего=Сумма+СуммаНДС;
	//КонецЕсли;
	
	СЗ = new map;
	szadd(СЗ, СуммаНДС, "СуммаНДС");
	szadd(СЗ, СтавкаНДС, "СтавкаНДС");    
	szadd(СЗ, СуммаВсего,"СуммаВсего");
	Возврат СЗ;
	
КонецФункции    


&НаСервере
procedure ContinueReadSessionData()
	// 
	mTables = new Map;
	For each t in tables6 do
		tt = t;
		if t = OutcomesByOffice then
			tt = t + "GB";
		endif;
		mTables.Insert(t, FormAttributeToValue(tt));
	enddo;
	TabFile = FormAttributeToValue("ТабФайл");
	TabFile.Clear();
	
	
	CatContr = Справочники.Контрагенты;
//	CatStores = Справочники.МестаХранения;
	CatStores = Справочники.Склады;
	CatWares = Справочники.Номенклатура;
//	CatWares = Справочники.Товары;
	CatNDS = Перечисления.СтавкиНДС;
	for each kv in mTables do		
		table = kv.Value;		
		tablename = kv.key;
		// Lab 017
		Если (tablename<>"OutcomesByRetail") И (tablename<>"OutcomesByOffice") И (tablename<>"ItemOutcomesByRetail") 
			И (tablename<>"IncomesByDischarge") И (tablename<>"TradeDocsInActs") И (tablename<>"TradeDocsInBills") Тогда
			Продолжить;
		КонецЕсли;	 
		
		for i = 0 to table.count() - 1 do
			
			str = table.get(i);
			
			if tablename = "OutcomesByRetail" then
				Если (str.PaymentModeExtCode="01ОК00") ИЛИ (str.PaymentModeExtCode="01ТК00") Тогда    
					Продолжить;
				КонецЕсли;				
			endif;
			Если tablename = "OutcomesByOffice" Тогда  
				Если (str.PaymentModeExtCode<>"01ОК00") И (str.PaymentModeExtCode<>"01ТК00") Тогда    
					Продолжить;
				КонецЕсли;
			КонецЕсли;         
			
			СтавкаНДС="";                                                                                                                                        
		
		// Lab 020
			rec = TabFIle.Add();
			rec.КонецСмены = str.КонецСмены;
			// Lab 018

			rec.КодАЗС = СокрЛП(str.КодАЗС);
			
			//fnd = CatStores.НайтиПоРеквизиту("КодСинх", СокрЛП(str.КодАЗС));
			fnd = CatStores.НайтиПоКоду(СокрЛП(str.КодАЗС));
			if fnd = CatStores.EmptyRef() then
			else
			endif;
			rec.Склад = fnd;
			//ВыбСклад = fnd;
			
			er = CatWares.EmptyRef();
			Если (tablename="OutcomesByRetail") 
				ИЛИ (tablename="OutcomesByOffice") ИЛИ (tablename="IncomesByDischarge") Тогда    
				
				rec.КодТовара=СокрЛП(str.FuelExtCode);
				
				//ware = CatWares.НайтиПоРеквизиту("КодТопаз",СокрЛП(str.FuelExtCode));
				ware = CatWares.НайтиПоКоду(СокрЛП(str.FuelExtCode));
				
				//ware.ЕдиницаИзмерения
				
				rec.Товар = ware;
				rec.Объем = stonum(str.Volume);
				Если (tablename="OutcomesByRetail") ИЛИ (tablename="OutcomesByOffice") Тогда
					rec.Плотность = ПолучитьПлотностьГСМ(str.КодАЗС,str.НомерСмены,str.TankNum);
					Если rec.Плотность = 0 Тогда  
						Message("Не введены данные о плотности!!! (Заполнение невозможно.)");
						// ПолноеИмяФайлаПриИзменении();
						// Возврат;          // !!!! cannot input number at server
					КонецЕсли;
					rec.Цена=Число(СтрЗаменить(str.OrigPrice,",","."));  
					rec.ВидДвижения="Продажа";
				Иначе
					
					rec.Плотность=Число(СтрЗаменить(str.Density,",","."))/1000;	   
					rec.ВидДвижения = "Приход";
				КонецЕсли;	
				rec.Колво = (rec.Объем*rec.Плотность) / 1000.0;
				//message("amount |" +  rec.Колво + "|"+rec.Объем+ "|"+rec.Плотность);
				rec.ЭтоГСМ = true;                          
				СтавкаНДС="";                                                                                                                                        
								
			ИначеЕсли (tablename="ItemOutcomesByRetail") ИЛИ (tablename="ItemOutcomesByOffice") 
				ИЛИ (tablename="TradeDocsInActs") ИЛИ (tablename="TradeDocsInBills") Тогда 
				
				rec.ВидДвижения="Продажа";
				rec.КодТовара=СокрЛП(str.ItemExtCode);
				//ware = CatWares.НайтиПоРеквизиту("КодТопаз",СокрЛП(str.ItemExtCode));
				ware = CatWares.НайтиПоКоду(СокрЛП(str.ItemExtCode));
				rec.Товар = ware;
				rec.Колво=Число(str.Quantity); 
				rec.Объем=0;   
				rec.Плотность=0;
				Если tablename="ItemOutcomesByRetail" Тогда 
					rec.Цена=Число(СтрЗаменить(str.PriceRetail,",",".")); 
					СтавкаНДС=Число(str.Nds); 
					Если str.IsReturn="1" Тогда
						rec.ВидДвижения="Возврат";	
					Иначе
						rec.ВидДвижения="Продажа";		
					КонецЕсли;
				ИначеЕсли tablename="TradeDocsInBills" Тогда 
					rec.Цена=Число(СтрЗаменить(str.Price,",",".")); 
					СтавкаНДС = Число(СтрЗаменить(str.NdsName,"%",""));    
					rec.Сумма = str.Amount;
					rec.НДС = str.NdsAmount;
					
					// TODO!!!!
					// выбирать из перечисления!
					
					/// nds = CatNDS.НайтиПоРеквизиту("Ставка", СтавкаНДС);
					nds = null;
										
					
					
					//СпрСтавкиНДС=СоздатьОбъект("Справочник.СтавкиНДС");
					//Если СпрСтавкиНДС.НайтиПоРеквизиту("Ставка",СтавкаНДС,1)=1 Тогда
					//	ТабФайл.СтавкаНДС=СпрСтавкиНДС.ТекущийЭлемент();
					//Иначе
					//	ТабФайл.СтавкаНДС = ПолучитьПустоеЗначение("Справочник.СтавкиНДС");  
					//КонецЕсли;
					
					rec.СтавкаНДС = nds;
					
					
                    rec.Всего=str.Total;             
					rec.ВидДвижения="Приход";
				Иначе
					rec.Цена=0; 
					СтавкаНДС="";                
					rec.ВидДвижения="Приход";
				КонецЕсли;	
				rec.ЭтоГСМ=0;
				
			else
				
			КонецЕсли;
			if rec.Товар <> er then
				// TODO!!!
				//ТабФайл.ЕдИзм=ТабФайл.Товар.ЕдиницаИзмеренияПоУмолчанию;
				rec.ЕдИзм = rec.Товар.ЕдиницаИзмерения;
			endif;			
			
			// Lab 021
			
			Если (tablename="OutcomesByRetail") 
				ИЛИ (tablename="OutcomesByOffice") ИЛИ (tablename="ItemOutcomesByRetail") Тогда
				ФормаОплаты=ПолучитьФормуОплаты(СокрЛП(str.PaymentModeExtCode),
					СокрЛП(str.PaymentModeName));
				rec.ФормаОплаты=ФормаОплаты.Получить("ДляТаблицы"); 
				rec.ФормаОплатыДляДокумента=ФормаОплаты.Получить("ДляДокумента"); 
				Если rec.ФормаОплатыДляДокумента<>"Переливы" Тогда
					rec.Сумма=stonum(str.Amount);
				Иначе
					rec.Сумма=rec.Объем*rec.Цена;
				КонецЕсли;	
				
				СтруктураНДС=РасчетНДС(rec.Товар,rec.Сумма,rec.КонецСмены, СтавкаНДС, true);
				rec.НДС = СтруктураНДС.Получить("СуммаНДС");
				rec.СтавкаНДС = СтруктураНДС.Получить("СтавкаНДС");
				rec.Всего = СтруктураНДС.Получить("СуммаВсего");  
				
			КонецЕсли;	
			rec.ФайлЗагрузки=str.ФайлЗагрузки;
			// Lab 022
			
			Если (tablename="TradeDocsInActs") ИЛИ (tablename="TradeDocsInBills") Тогда    
				КодКонтрагента=СокрЛП(str.FirmsExtCode);   
			Иначе
				КодКонтрагента=СокрЛП(str.PartnerExtCode);
			КонецЕсли;           
			
			Если СокрЛП(rec.ВидДвижения)="Продажа" Тогда 
				Если rec.ФормаОплатыДляДокумента="Переливы" Тогда
					rec.Клиент = ВыбКонтрагентДляПереливов;          
					rec.КодКлиента = ВыбДоговорКонтрагентаДляПереливов.Код;
					rec.Договор = ВыбДоговорКонтрагентаДляПереливов;
				ИначеЕсли КодКонтрагента="" Тогда 
					rec.Клиент = ВыбКонтрагент;     
					rec.КодКлиента="<частное лицо>"; 
					rec.Договор=?(rec.ЭтоГСМ,ВыбДоговорГСМ,ВыбДоговорТовар);
				Иначе       
					rec.КодКлиента = КодКонтрагента;
					message("client to find " + КодКонтрагента);
					//cc = CatContr.НайтиПоРеквизиту("КодТопаз", КодКонтрагента); // 15
					cc = CatContr.НайтиПоКоду(КодКонтрагента + "     "); // 15
					if cc = Undefined then
						message("not found client undef ");
					endif;
					
					Если cc <> CatContr.EmptyRef() and cc <> Undefined Тогда
						rec.Клиент = cc;     
						
						message("found client " + cc);
						
						Если false // TODO!!
							//мДоговоры.НайтиЗначение(ЗначениеВСтрокуВнутр(ТабФайл.Клиент)
							//+ЗначениеВСтрокуВнутр(ВыбФирма)
							//+ЗначениеВСтрокуВнутр(ТабФайл.ЭтоГСМ),Стр,"Индекс")=1 
							Тогда
								
							//rec.Договор=мДоговоры.ПолучитьЗначение(Стр,"Договор");  
							//Если rec.Договор.Фирма<>ВыбФирма Тогда
							//	rec.Договор="";
							//КонецЕсли;	
							
						Иначе
							  dog = Справочники.ДоговорыКонтрагентов;
							  cond = Новый Структура("Контрагент");
							  empty = CatContr.EmptyRef();
							  sel = dog.select(,,cond);
							  while sel.next() do
								  obj  = sel.GetObject();
								  message("Got " + obj.Контрагент.Наименование);
							  enddo;
							  
						endif;
						
					else
						rec.Клиент = CatContr.EmptyRef();
						message("client not found");
					endif;
					
				endif;	
				
			else
			endif;
			
		enddo;
		
	enddo;
		
	// at end
	
	for each s in tabfile do
		if s.ВидДвижения = "Приход" then
			tabfile.delete(s);
		endif;
	enddo;
	
	
	tabfile.GroupBy("НомСтр,ВидДвижения,КонецСмены,КодАЗС,"+
		"Склад,КодКлиента,Клиент,Договор,КодТовара,Товар,ЭтоГСМ,"+
		"Плотность,ФормаОплаты,ФормаОплатыДляДокумента,ЕдИзм,Цена,СтавкаНДС,ФайлЗагрузки",
		"Колво,Объем,Сумма,НДС,Всего"); 
	tabfile.sort("КонецСмены,КодАЗС,ВидДвижения,ФормаОплаты,ЭтоГСМ Убыв,Клиент,Договор"); 
	
	k = 1;
	for each s in tabfile do
		s.НомСтр = k;	
		k = k + 1;
	enddo;
	
	ЗаполнитьИтоги(tabfile);
	
	ValueToFormAttribute(tabfile, "ТабФайл");
	stage = 4;
	
endprocedure

&НаСервере
procedure ЗаполнитьИтоги(tabfile)
	tsumm = FormAttributeToValue("ТИтоги");
	tsumm.clear();
	osumm = FormAttributeToValue("ОИтоги");
	osumm.clear();
	for each str in tabfile do
		if str.ЭтоГСМ then
			rec = tsumm.add();
			rec.ВидДвижения = str.ВидДвижения;
			rec.Товар = str.Товар;
			rec.Колво = str.Колво;
		else
			rec = osumm.add();
			rec.ВидДвижения = str.ВидДвижения;
			rec.ФормаОплаты = str.ФормаОплаты;
			rec.Клиент = str.Клиент;
			//rec.Колво = str.Колво;
			rec.Всего = str.Всего;
			
		endif;
		
	enddo;
	
//	ТИтоги.Свернуть("ВидДвижения,Товар,ЕдИзм","Колво,Объем,ОбъемПрокачка,Сумма,НДС,Всего"); 
//	ТИтоги.Сортировать("ВидДвижения,Товар");   

	tsumm.Свернуть("ВидДвижения,Товар","Колво"); 
	tsumm.Сортировать("ВидДвижения,Товар");   
	
//	фИтогиФормаОплаты.Свернуть("КонецСмены,Склад,ВидДвижения,ФормаОплаты,Клиент","Всего"); 
//	фИтогиФормаОплаты.Сортировать("ВидДвижения,ФормаОплаты,Клиент");  

	osumm.Свернуть("ВидДвижения,ФормаОплаты,Клиент","Всего"); 

	ValueToFormAttribute(tsumm,"ТИтоги");
	ValueToFormAttribute(osumm,"ОИтоги");
	
	
endprocedure


&НаСервере
Процедура ЧитатьДанныеСессии(XMLString, ИмяФайлаЗагрузки)
	Message("stage " + stage);
	if stage < 2 then
		Message("DataPaket does not opened");
		return;
	endif;
	
	S = Новый ОписаниеТипов("Строка");
	D = Новый ОписаниеТипов("Число",
        Новый КвалификаторыЧисла(15, 2));
	D10 = Новый ОписаниеТипов("Число",
        Новый КвалификаторыЧисла(10, 0));
	D10_5 = Новый ОписаниеТипов("Число",
        Новый КвалификаторыЧисла(10, 5));
	D1 = new TypeDescription("Число",
        New NumberQualifiers(2, 0));
		
		
	D2 = Новый ОписаниеТипов("Число",
        Новый КвалификаторыЧисла(2, 0));
	C = Новый ОписаниеТипов("Дата");
	Message("stage " + stage);
	
	ClearTables();

	mXMLTableList = New Map;
	
	ColMap01 = New Map;
	Index01 = 0;
		
	Парсер = Новый ЧтениеXML;
	Парсер.УстановитьСтроку(XMLString); 
    Построитель = Новый ПостроительDOM;
    Док = Построитель.Прочитать(Парсер);
	
	DataPacket = Док.FirstChild;
	Если (DataPacket.ИмяУзла = "DataPaket") Тогда
		AZSCode = DataPacket.GetAttribute("AZSCode");
		//Сообщить(AZSCode);
		SessionList = DataPacket.GetElementByTagName("Sessions")[0].ChildNodes;
		
		For Each Session in SessionList Do
			
			
			НачалоСмены = Session.ПолучитьАтрибут("StartDateTime");
			КонецСмены = Session.ПолучитьАтрибут("EndDateTime");
			ОператорСмены = Session.ПолучитьАтрибут("UserName");
			НомерСмены = Session.ПолучитьАтрибут("SessionNum");
			
			StartDateTime = Session.GetAttribute("StartDateTime");
			//Сообщить(StartDateTime);
			//Сообщить(Session.ChildNodes);
			For Each Node in Session.ChildNodes Do
				//Сообщить(Node.NodeName);
				if Node.ChildNodes.Count() = 0 then   // Lab 001
					Continue;
				Endif;
				//ТаблицаИзXML = mXMLTableList.FindByValue.(Node.NodeName);
				
				IF mXMLTableList.Get(Node.NodeName) = undefined then
					
				    ТаблицаИзXML = new ТаблицаЗначений;
					
					//Message("New Table " + Node.NodeName);
					ColMap01.Insert(Node.NodeName, new Map);
					Index01 = 0;
					For Each StrNode in Node.ChildNodes Do
						//Сообщить("-- " + StrNode.NodeName);
						if StrNode.ChildNodes.Count() = 0 then   // Lab 002
							Continue;
						Endif;
					EnddO;
					For Each attr in StrNode.attributes do
							ColName = attr.Name;
							// Message("New col " + ColName);
							Если (Найти(ColName,"Volume")>0) 
								ИЛИ (Найти(ColName,"Amount")>0) 
								ИЛИ (Найти(ColName,"Mass")>0) Тогда
								
								ТаблицаИзXML.Колонки.Добавить(ColName,D);
								ColMap01[Node.NodeName].Insert(ColName, Index01);
								Index01 = Index01 + 1;
								
							Иначе       								
								ТаблицаИзXML.Колонки.Добавить(ColName);
								ColMap01[Node.NodeName].Insert(ColName, Index01);
								Index01 = Index01 + 1;
							КонецЕсли;
							
					enddo;	
					Если (StrNode.NodeName = "TradeDocsInAct") // Lab 003
								ИЛИ (StrNode.NodeName = "TradeDocsInBill") Тогда
								//XMLУзелСтрокиСтроки = XMLУзелСтроки.ПолучитьПодчиненныйПоНомеру(1);
						For Each StrStrNode in StrNode.ChildNodes do // Single child!!
									
							For each attr in StrStrNode.attributes do
									ColName = attr.Name;
							//		Message("new col  " + ColName);
									Если (Найти(ColName,"Volume") > 0) 
										ИЛИ (Найти(ColName,"Amount") > 0) 
										ИЛИ (Найти(ColName,"Mass") > 0) Тогда
										ТаблицаИзXML.Колонки.Добавить(ColName,D);
										ColMap01[Node.NodeName].Insert(ColName, Index01);
										Index01 = Index01 + 1;
										
									Иначе                                      
							//			Message("Bad colname? " + ColName +" (" + StrStrNode.NodeName);
										ТаблицаИзXML.Колонки.Добавить(ColName);
										ColMap01[Node.NodeName].Insert(ColName, Index01);
										Index01 = Index01 + 1;
										
									КонецЕсли;
							enddo;								
							Break; // ???!!!
								
						enddo;
					ИначеЕсли StrNode.NodeName = "OutcomeByOffice" Тогда
							//ТаблицаИзXML.Колонки.Добавить("OutcomeByOffice"); 
							
							ColName = "PartnerExtCode";
							ТаблицаИзXML.Колонки.Добавить(ColName);
							//message(Node.NodeName + " added col PartnerExtCode");
							
							ColMap01[Node.NodeName].Insert(ColName, Index01);
							Index01 = Index01 + 1;
							
					КонецЕсли;
					
					///----
					ColName = 	"КодАЗС";
					ТаблицаИзXML.Колонки.Добавить(ColName, D10, "Код АЗС");
					ColMap01[Node.NodeName].Insert(ColName, Index01);
					Index01 = Index01 + 1;
					ColName = "НомерСмены";
					ТаблицаИзXML.Колонки.Добавить(ColName, D10);
					ColMap01[Node.NodeName].Insert(ColName, Index01);
								Index01 = Index01 + 1;
					ColName = "НачалоСмены";
					ТаблицаИзXML.Колонки.Добавить(ColName, C);
								ColMap01[Node.NodeName].Insert(ColName, Index01);
								Index01 = Index01 + 1;
					ColName = "КонецСмены";
					ТаблицаИзXML.Колонки.Добавить(ColName, C);
								ColMap01[Node.NodeName].Insert(ColName, Index01);
								Index01 = Index01 + 1;
					ColName = "ОператорСмены";
					ТаблицаИзXML.Колонки.Добавить(ColName, S);
								ColMap01[Node.NodeName].Insert(ColName, Index01);
								Index01 = Index01 + 1;
					ColName = "ФайлЗагрузки";
					ТаблицаИзXML.Колонки.Добавить(ColName, S);
								ColMap01[Node.NodeName].Insert(ColName, Index01);
								Index01 = Index01 + 1;
					ColName = "HasOrder";
					ТаблицаИзXML.Колонки.Добавить(ColName, D1); // d2 in fact
								ColMap01[Node.NodeName].Insert(ColName, Index01);
								Index01 = Index01 + 1;
					/// ----								
					
					
				EndIf; // table undef
				//Message("ColumnsCount " + ТаблицаИзXML.columns.count());
				//for each Col in ТаблицаИзXML.columns do
				//	Message("ColName " + col.Name);
				//enddo;
				
				for each NodeStr in Node.ChildNodes do
					
					if (NodeStr.NodeName <> "TradeDocsInAct") 
						and (NodeStr.NodeName <> "TradeDocsInBill") then
						Rec = ТаблицаИзXML.Add();

						for each attr in NodeStr.attributes do
							ColName = attr.Name;	    // Lab 007
							// Message("attr2 " + ColName);
							ColValue = Attr.Value;
							if ЭтоЧисло(ColValue) then
								COlValue = StrReplace(colValue, ",", ".");							
							endif;
							
							Rec[ColMap01[Node.NodeName][ColName]] = ColValue;
						enddo;
						
						if (NodeStr.NodeName  = "OutcomeByOffice") then                // ????
							for each NodeStrStr in NodeStr.ChildNodes do // Lab 008
								ColName = NodeStrStr.NodeName;
								if ColName = "PartnerExtCode" then
									Rec[ColMap01[Node.NodeName][ColName]] = NodeStrStr.TextContent;
								endif;
							enddo;
						endif;
						// Lab 009
						
						///----
					    Rec.КодАЗС = AzsCode;
						Rec.НомерСмены = Число(НомерСмены);
						Rec.НачалоСмены = НачалоСмены;
						Rec.КонецСмены = КонецСмены;
						Rec.ОператорСмены = ОператорСмены;
						Rec.ФайлЗагрузки = ИмяФайлаЗагрузки;
						Rec.HasOrder = 0;
						/// ----								
						
						
					else  // Lab 010
						For each nodeStrStr in NodeStr.ChildNodes do
							Rec = ТаблицаИзXML.Add();
							
							For each attr in NodeStr.attributes do
								ColName = attr.Name;
								ColValue = attr.Value;
								if ЭтоЧисло(ColValue) then
									COlValue = StrReplace(colValue, ",", ".");							
								endif;
								Rec[ColMap01[Node.NodeName][ColName]] = ColValue;
							enddo;
							
							For Each attr in NodeStrStr.attributes do
								ColName = attr.Name;
								ColValue = attr.Value;
								if ЭтоЧисло(ColValue) then
									COlValue = StrReplace(colValue, ",", ".");							
								endif;
								Rec[ColMap01[Node.NodeName][ColName]] = ColValue;
							enddo;
							// Lab 012
							Rec.КодАЗС = AzsCode;
							Rec.НомерСмены = Число(НомерСмены);
							Rec.НачалоСмены = НачалоСмены;
							Rec.КонецСмены = КонецСмены;
							Rec.ОператорСмены = ОператорСмены;
							Rec.ФайлЗагрузки = ИмяФайлаЗагрузки;
							Rec.HasOrder = 0;
							
						enddo;						
					endif;					
				enddo;
				
				
				// lab 005
				mXMLTableList.Insert (Node.NodeName,ТаблицаИзXML);   
				// lab 006
								
			Enddo;
			tcnt = mXMLTableList.Count();
			Message("table count " + tcnt);
		Enddo;
	else
		Message("Not DataPaket XML.");
		return;		
	endif;
	
	table = mXMLTableList["Tanks"];
	
	if table = Undefined then
		Message("Not enough data in XML.");
		return;
	endif;
	// Lab 013
		
	Dens0 = New ValueTable;
	Dens0.Columns.Add("TankNum", D2);	
	Dens0.Columns.Add("Density", D10_5);
	Dens0.Columns.Add("Индекс");
	
	for i = 0 to table.count() - 1 do
		str = table.get(i);
		rec = dens0.add();
		rec.TankNum = Число(СокрЛП(str.TankNum));
		strdens = str.EndDensity;
		if strdens = "" then
			strdens = "0.0";
		endif;
		
		rec.Density = Число(СтрЗаменить(strDens,",","."))/1000;
		rec.Индекс = ЗначениеВСтрокуВнутр(str.КодАЗС)
			+ЗначениеВСтрокуВнутр(str.НомерСмены)
			+ЗначениеВСтрокуВнутр(Число(СокрЛП(str.TankNum)));
	enddo;
		
	ChangeRequisites(Dens0, "Dens");
	ЗначениеВРеквизитФормы(Dens0, "Dens");
	
	// Lab 014
	
	For each kv in mXMLTableList do
		tablename = kv.key;
		table = kv.value;
		//message("Table " + tablename);
		Если (tablename<>"OutcomesByRetail") И (tablename<>"OutcomesByOffice") И (tablename<>"ItemOutcomesByRetail") 
			И (tablename<>"IncomesByDischarge") И (tablename<>"TradeDocsInActs") И (tablename<>"TradeDocsInBills") Тогда
			Продолжить;
		КонецЕсли;	 
		Stage = 3;	
		message("stage " + stage);
		
		if tablename = "OutcomesByOffice" then
		    	//???		
	    	//Message(DateList);
			DateList.Clear();
//			ПрочитатьСуммуЦенуОбъемИзФайлаОрдера(ТаблицаИзXML);  // in ReadOrders
			for i = 0 to table.count() - 1 do
				str = table.get(i);
				if Datelist.FindByValue(str.Date) = Undefined then
					DateList.Add(str.Date);
				endif;
		
			enddo;
			// in readOrders
			//table.GroupBy("TankNum,OrigPrice,PaymentModeExtCode,FuelExtCode,PaymentModeName,FuelName,PartnerExtCode,КодАЗС,НомерСмены,НачалоСмены,КонецСмены,ОператорСмены,ФайлЗагрузки","Mass,Volume,Amount");
			
		endif;
		// here by retail
		// and by offices
		//Message("c " + tablename);
		
	enddo;
	
	For each kv in mXMLTableList do
		tablename = kv.key;
		table = kv.value;
		//message("Table " + tablename);
		if not tables6.find(tablename) = Undefined then
			ChangeRequisites(table, tablename);
			ValueToFormAttribute(table, tablename);
		endif;
						
	enddo;

КонецПроцедуры	

&НаСервере
function CreateDocs()
	if stage < 4 then
		message("files not parsed  yet");
		return null;
	endif;
	
	post = ?(DoPostDoc, DocumentWriteMode.Posting, DocumentWriteMode.Write);
	
	tabfile = FormAttributeToValue("ТабФайл");
	for each str in tabfile do
		
		if false and str.ВидДвижения = "Приход" then // skip it
			doc = Документы.ПеремещениеТоваров.CreateDocument();
			doc.Дата = CurrentDate();
						
			if str.ЭтоГСМ then
				doc.СкладОтправитель = ВыбСкладОтправитель;
			else
				doc.СкладОтправитель = ВыбСкладОтправительФасовка;
			endif;	
			doc.СкладПолучатель = str.Склад;
			
			// doc.Организация = Справочники.Организации.
			
			warep = doc.Товары.Добавить();
			warep.Номенклатура = str.Товар;
		//ware.Количество = ?(str.ЭтоГСМ, str.Объем, str.Колво);
			warep.КоличествоУпаковок = str.Колво;
			
			try
				doc.Write(post);
				Message("written " + str.ВидДвижения + " ware: " + str.Товар.Наименование);
			except
				Message("write failed: " + ErrorDescription() + "| contr " + str.Клиент.Наименование + " "
					+ str.ВидДвижения + " ware " +  str.Товар.Наименование);
			endtry;
			
			
		else	
			
			doc = Документы.РеализацияТоваровУслуг.CreateDocument();
			doc.Дата = CurrentDate();
		
		//?
			doc.Партнер = str.Клиент;
		    doc.Контрагент = str.Клиент;
			doc.Склад = ВыбСклад;
		
		//?
//		doc.ХозяйственнаяОперация =   
//			ХозяйственныеОперации.РеализацияВРозницу;
			
		//			
			doc.ЦенаВключаетНДС = true;
			doc.НалогообложениеНДС = 
				Перечисления.ТипыНалогообложенияНДС.ПродажаОблагаетсяНДС;
			
			doc.Склад = ВыбСклад;
			
		// doc.Менеджер = 	
		
			ware = doc.Товары.Добавить();
			ware.Номенклатура = str.Товар;
			//ware.Количество = ?(str.ЭтоГСМ, str.Объем, str.Колво);
			ware.Количество = str.Колво;
			ware.КоличествоУпаковок = str.Колво;
			ware.Цена = str.Цена;
		    ware.Сумма = str.Сумма;
		// ware.Упаковка = 
		
		// TODO!!! 
			ware.СтавкаНДС = Перечисления.СтавкиНДС.НДС18;
			//  = str.СтавкаНДС
		
			//ware.Сумма = str.Сумма;
			try
				doc.Write(post);
				Message("written " + str.ВидДвижения + " ware: " + str.Товар.Наименование);
			except
				Message("write failed: " + ErrorDescription() + "| contr " + str.Клиент.Наименование + " "
					+ str.ВидДвижения + " ware " +  str.Товар.Наименование);
			endtry;
		
		endif;
	
	enddo;
	
	
	return null; // doc.ref;
endfunction


&НаСервере
Процедура ПриЗакрытииНаСервере()
	SaveOptions();
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	ПриЗакрытииНаСервере();
КонецПроцедуры

tables6 = new array();
tables6.add("TradeDocsInActs");
tables6.add("TradeDocsInBills");
tables6.add("OutcomesByRetail");
tables6.add("OutcomesByOffice");
tables6.add("IncomesByDischarge");
tables6.add("ItemOutcomesByRetail");
 