
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
	КонецЕсли;	
	
endProcedure

&НаСервере
Процедура ПриОткрытииНаСервере()
	// Вставить содержимое обработчика.
КонецПроцедуры

&НаСервере
Процедура СоздатьТаблицы()
	
	S = Новый ОписаниеТипов("Строка");
	D = Новый ОписаниеТипов("Число",
        Новый КвалификаторыЧисла(15, 2));
		
	t = РеквизитФормыВЗначение("ТабФайл");
	
	t.Колонки.Добавить("НомСтр", D, "№");
	t.Колонки.Добавить("ВидДвижения", S, "ВидДвижения");
					
	НовыеРеквизиты = Новый Массив;
	
    Для Каждого Колонка Из t.Колонки Цикл
         НовыеРеквизиты.Добавить(
            Новый РеквизитФормы(
                Колонка.Имя, Колонка.ТипЗначения,
                "ТабФайл"
            )
         );
	КонецЦикла;	
		 
	ИзменитьРеквизиты(НовыеРеквизиты);
	
	Для Каждого Колонка Из t.Колонки Цикл
		Колонка.Заголовок = Колонка.Имя + "HEAD";      // ?
        НовыйЭлемент = Элементы.Добавить(
            "" + t + "_" + Колонка.Имя, Тип("ПолеФормы"), Элементы["ТабФайлФ"]
        );
        НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
        НовыйЭлемент.ПутьКДанным = "ТабФайл" + "." + Колонка.Имя;
    КонецЦикла;
	ЗначениеВРеквизитФормы(t, "ТабФайл");
	
	
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

&НаСервере
procedure ChangeRequisites(table, tablename)
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
            "" + table + "_" + Колонка.Имя, Тип("ПолеФормы"), Элементы[tablename]
        );
        НовыйЭлемент.Вид = ВидПоляФормы.ПолеВвода;
        НовыйЭлемент.ПутьКДанным = tablename + "." + Колонка.Имя;
    КонецЦикла;
	//ЗначениеВРеквизитФормы(table, tablename);
	
	
endProcedure	

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Сообщить("CP02", СтатусСообщения.Внимание);	

	ПриОткрытииНаСервере();
	СоздатьТаблицы();
	
	Сообщить(мТехПрокачка, СтатусСообщения.Внимание);	
	
КонецПроцедуры

&НаКлиенте
Procedure ReadFile(command)
	XMLString = "";
	Текст = Новый ЧтениеТекста(ПолноеИмяФайла);
	Пока Истина Цикл
        Строка = Текст.ПрочитатьСтроку();
        Если Строка = Неопределено Тогда
            Прервать;
		Иначе
			XmlString = XmlString + Строка;
    //        Сообщить(Строка);
        КонецЕсли;
	КонецЦикла;
	
	//Парсер = Новый ЧтениеXML;
	//Парсер.УстановитьСтроку(XMLString);
 
    //Построитель = Новый ПостроительDOM;
 
    //Документ = Построитель.Прочитать(Парсер);
	//Сообщить(Документ);
	ЧитатьДанныеСессии(XMLString);
EndProcedure	

#КонецОбласти

&НаСервере
Функция ЭтоЧисло(Знач ТекСтр)  
	
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

&НаСервере
Процедура ЧитатьДанныеСессии(XMLString)
	S = Новый ОписаниеТипов("Строка");
	D = Новый ОписаниеТипов("Число",
        Новый КвалификаторыЧисла(15, 2));
	C = Новый ОписаниеТипов("Дата");

	мСписокТаблицИзXML = New Map;
	
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
			StartDateTime = Session.GetAttribute("StartDateTime");
			Сообщить(StartDateTime);
			Сообщить(Session.ChildNodes);
			For Each Node in Session.ChildNodes Do
				Сообщить(Node.NodeName);
				if Node.ChildNodes.Count() = 0 then   // Lab 001
					Continue;
				Endif;
				//ТаблицаИзXML = мСписокТаблицИзXML.FindByValue.(Node.NodeName);
				
				IF мСписокТаблицИзXML.Get(Node.NodeName) = undefined then
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
							Message("New col " + ColName);
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
									Message("new col  " + ColName);
									Если (Найти(ColName,"Volume") > 0) 
										ИЛИ (Найти(ColName,"Amount") > 0) 
										ИЛИ (Найти(ColName,"Mass") > 0) Тогда
										ТаблицаИзXML.Колонки.Добавить(ColName,D);
										ColMap01[Node.NodeName].Insert(ColName, Index01);
										Index01 = Index01 + 1;
										
									Иначе                                              
										ТаблицаИзXML.Колонки.Добавить(ColName);
										ColMap01[Node.NodeName].Insert(ColName, Index01);
										Index01 = Index01 + 1;
										
									КонецЕсли;
							enddo;								
								
						enddo;
					ИначеЕсли StrNode.NodeName = "OutcomeByOffice" Тогда
							//ТаблицаИзXML.Колонки.Добавить("OutcomeByOffice"); 
							
							ColName = "PartnerExtCode";
							ТаблицаИзXML.Колонки.Добавить(ColName);
							message(Node.NodeName + " added col PartnerExtCode");
							
							ColMap01[Node.NodeName].Insert(ColName, Index01);
							Index01 = Index01 + 1;
							
					КонецЕсли;
					
					///----
					ColName = 	"КодАЗС";
					ТаблицаИзXML.Колонки.Добавить(ColName, D);
					ColMap01[Node.NodeName].Insert(ColName, Index01);
					Index01 = Index01 + 1;
					ColName = "НомерСмены";
					ТаблицаИзXML.Колонки.Добавить(ColName, D);
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
							
							//Message("attrVal " + ColValue);
							Rec[ColMap01[Node.NodeName][ColName]] = ColValue;
							//cnt = ТаблицаИзXML.Count();
							//AddedRec = ТаблицаИзXML.Get(cnt - 1);
							
							//Message("AddedVal " 
							//	+ ColName + " ind " + 
							//		ColMap01[Node.NodeName][ColName] + " " 
							//		+ AddedRec[ColMap01[Node.NodeName][ColName]]);
						enddo;
						
						if (NodeStr.NodeName  = "OutcomeByOffice") then                // ????
							for each NodeStrStr in NodeStr.ChildNodes do // Lab 008
								ColName = NodeStrStr.NodeName;
								if ColName = "PartnerExtCode" then
						//			Message(ColName + " (pec) " + NodeStrStr.NodeValue);
									Rec[ColMap01[Node.NodeName][ColName]] = NodeStrStr.NodeValue;
								endif;
							enddo;
						endif;
						// Lab 009
						
						///----
					
						/// ----								
						
						
					else  // Lab 010
						For each nodeStrStr in NodeStr do
							Rec = ТаблицаИзXML.Add();
							
							For each attr in NodeStr.attributes do
								ColName = attr.Name;
								ColValue = attr.Value;
								if ЭтоЧисло(ColValue) then
									COlValue = StrReplace(colValue, ",", ".");							
								endif;
								Rec[ColMap01[Node.NodeName][ColName]] = ColValue;
							enddo;
							
							For Each attr in NodeStrStr do
								ColName = attr.Name;
								ColValue = attr.Value;
								if ЭтоЧисло(ColValue) then
									COlValue = StrReplace(colValue, ",", ".");							
								endif;
								Rec[ColMap01[Node.NodeName][ColName]] = ColValue;
							enddo;
							
						enddo;						
						
					endif;
					
					
				enddo;
				
				
				// lab 005
				мСписокТаблицИзXML.Insert (Node.NodeName,ТаблицаИзXML);   
				// lab 006
								
			Enddo;
			tcnt = мСписокТаблицИзXML.Count();
			Message("table count " + tcnt);
		Enddo;
		
	КонецЕсли;	
	
	// Lab 013
	
	// Lab 014
	
	For each kv in мСписокТаблицИзXML do
		tablename = kv.key;
		table = kv.value;
		message("Table " + tablename);
		
		if tablename = "OutcomesByOffice" then
			OutBOTableName = tableName;
			ChangeRequisites(table, "OutBOTable");
			ЗначениеВРеквизитФормы(table, "OutBOTable");
			//ОбновитьОтображениеДанных();
			ЭтаФорма.Прочитать();
		endif;
		
	enddo;
	
		
КонецПроцедуры	
