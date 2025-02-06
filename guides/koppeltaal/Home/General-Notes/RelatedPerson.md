---
topic: RelatedPerson
---

# {{page-title}}

De Resource `RelatedPerson` is een nieuwe actor in de Koppeltaal Standaard. Bij een Related Person kunnen allerlei personen zijn, denk aan de volgende Rollen en Relaties.

* Ouder of Voogd,
* Gemachtigde
* Zorg Ondersteuner
* etc.

In het Element `RelatedPerson.relationship` wordt deze relatie vastgelegd. 
In het Element `RelatedPerson.patient` bevat de referentie naar de `Patient`. Waarvoor betreffende actor een `RelatedPerson` is.

De `RelatedPerson` kan namens de `Patient` Taken uitvoeren, kan meekijken en ondersteunen bij taken van de `Patient`. Daarnaast heeft de `Patient` en `Practitioner` de mogelijkheid om de `RelatedPerson` toegang te ontzeggen aan een taak die was toegekend aan de `RelatedPerson`. 

Hieronder wordt beschreven welke elementen een rol spelen bij het uitvoeren, meekijken en ontzeggen van toegang:

## Taak uitvoeren door de RelatedPerson

Wanneer een `RelatedPerson` een taak uitvoert en start via een launch 
 1. De owner van de `Task` kan een `RelatedPerson` zijn: `Task.owner` = `Reference (KT2_RelatedPerson)` & `Task.for` = `Reference (KT2_Patient)`
 2. De owner van `Task` kan ook een `CareTeam` waar `CareTeam.subject`= `Reference (KT2_Patient)` & `CareTeam.participant.member` = `Reference(KT2_RelatedPerson)` & `RelatedPerson.patient` = `Reference (KT2_Patient)` & `CareTeam.subject`=`RelatedPerson.patient`. 

Deze condities moeten gecontroleerd worden door de lancerende applicatie.

## Meekijken en ondersteunen bij een taak van de Patient
Om het een `RelatedPerson` te laten meekijken met een taak van de patient zijn de volgende voorwaarden noodzakelijk.

 1. De Taak die `RelatedPerson` uitvoert, moet een subtaak zijn van de hoofdtaak die door de Patient wordt uitgevoerd: `Task.partOf` = `Reference (KT2_Task)` & `Task.owner` = `Reference` (KT2_RelatedPerson) & `Task.code`=`view`

Het ontzeggen van bevoegdheid om een taak door een `RelatedPerson` te laten uitvoeren

Om duidelijk te maken dat een `RelatedPerson` niet meer bevoegd is tot het uitvoeren of inzien van een taak zijn er de volgende opties:
 1. `Task.status` = `cancelled` 
 2. `RelatedPerson.active` = `0` (inactive) 
 3. `RelatedPerson.patient` <> `Task.owner`
 4. `CareTeam.participant.kt2contactperson` is verwijderd uit het `CareTeam`

