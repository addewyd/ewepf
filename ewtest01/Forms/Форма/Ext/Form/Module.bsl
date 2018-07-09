&AtServer
var tables6;

#Область ОбработчикиКомандФормы

&НаКлиенте
procedure OpenFile(command)
	
	Сообщить("CP01-", СтатусСообщения.Внимание);
	
	ДиалогФыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогФыбораФайла.Фильтр = "XML (*.xml)|*.xml";
	ДиалогФыбораФайла.Заголовок = "Выберите файл";                                         
	ДиалогФыбораФайла.ПредварительныйПросмотр = false;
	ДиалогФыбораФайла.ИндексФильтра = 0;
	Если ДиалогФыбораФайла.Выбрать() Тогда
   		// Действия, выполняемые тогда, когда файл выбран.
		ПолноеИмяФайла = ДиалогФыбораФайла.ПолноеИмяФайла;
		stage = 1;
	КонецЕсли;	
	
endProcedure

&НаСервере
Процедура ПриОткрытииНаСервере()
	// Вставить содержимое обработчика.
	Message("SOpen");
	Message("stage " + stage);
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	// Вставить содержимое обработчика.
	Message("SCreate");
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Сообщить("COpen", СтатусСообщения.Внимание);	
	Stage = 0;
	ПриОткрытииНаСервере();
	СоздатьТаблицы();
	
	Сообщить(мТехПрокачка, СтатусСообщения.Внимание);	
	
КонецПроцедуры

&НаКлиенте
Procedure ReadFile(command)
	XMLString = "";
	if stage < 1 then
		Message("DataPaket does not chosen");
		return;
	endif;
	
	Текст = Новый ЧтениеТекста(ПолноеИмяФайла);
	Пока Истина Цикл
        Строка = Текст.ПрочитатьСтроку();
        Если Строка = Неопределено Тогда
            Прервать;
		Иначе
			XmlString = XmlString + Строка;
			Stage = 2;
        КонецЕсли;
	КонецЦикла;
	
	ЧитатьДанныеСессии(XMLString, ПолноеИмяФайла);
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


#КонецОбласти

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
					
					Message("found");
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
		
		
			rec = TabFIle.Add();
			rec.КонецСмены = str.КонецСмены;
			// Lab 018
			rec.КонецСмены = str.КонецСмены;
			rec.КодАЗС = СокрЛП(str.КодАЗС);
		enddo;
		
	enddo;
	
	
	// at end
	tabfile.GroupBy("НомСтр,ВидДвижения,КонецСмены,КодАЗС,"+
		"Склад,КодКлиента,Клиент,Договор,КодТовара,Товар,ЭтоГСМ,"+
		"Плотность,ФормаОплаты,ФормаОплатыДляДокумента,ЕдИзм,Цена,СтавкаНДС,ФайлЗагрузки",
		"Колво,Объем,Сумма,НДС,Всего"); 
	// tabfile.sort
	
	
	ValueToFormAttribute(tabfile, "ТабФайл");
	
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
		Сообщить(AZSCode);
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
					
					Message("New Table " + Node.NodeName);
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
				Message("ColumnsCount " + ТаблицаИзXML.columns.count());
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
	
	for i = 0 to table.count() - 1 do
		str = table.get(i);
		rec = dens0.add();
		rec.TankNum = Число(СокрЛП(str.TankNum));
		strdens = str.EndDensity;
		if strdens = "" then
			strdens = "0.0";
		endif;
		
		rec.Density = Число(СтрЗаменить(strDens,",","."))/1000;
	enddo;
		
	ChangeRequisites(Dens0, "Dens");
	ЗначениеВРеквизитФормы(Dens0, "Dens");
	
	// Lab 014
	
	For each kv in mXMLTableList do
		tablename = kv.key;
		table = kv.value;
		message("Table " + tablename);
		Если (tablename<>"OutcomesByRetail") И (tablename<>"OutcomesByOffice") И (tablename<>"ItemOutcomesByRetail") 
			И (tablename<>"IncomesByDischarge") И (tablename<>"TradeDocsInActs") И (tablename<>"TradeDocsInBills") Тогда
			Продолжить;
		КонецЕсли;	 
		Stage = 3;	
		
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
		Message("c " + tablename);
		
	enddo;
	
	For each kv in mXMLTableList do
		tablename = kv.key;
		table = kv.value;
		message("Table " + tablename);
		if not tables6.find(tablename) = Undefined then
			ChangeRequisites(table, tablename);
			ValueToFormAttribute(table, tablename);
		endif;
						
	enddo;

КонецПроцедуры	

tables6 = new array();
tables6.add("TradeDocsInActs");
tables6.add("TradeDocsInBills");
tables6.add("OutcomesByRetail");
tables6.add("OutcomesByOffice");
tables6.add("IncomesByDischarge");
tables6.add("ItemOutcomesByRetail");
 