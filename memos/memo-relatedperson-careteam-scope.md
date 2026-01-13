# Memo: Scope RelatedPerson, Practitioner en CareTeam in Koppeltaal

**Datum:** 2026-01-08 **Status:** Concept **Doelgroep:** Standaardisatieteam **Referentie:** KPTSD-893

---

## 1\. Inleiding

Deze memo beschrijft de scope van RelatedPerson, Practitioners en CareTeam binnen de Koppeltaal standaard. De aanleiding is de behoefte om de zorgcontext (personen rondom de patiënt) beter te kunnen communiceren, met name voor RelatedPersons (naasten/verwanten).

Het doel van deze memo is om de verschillende aspecten bijeen te brengen en de scope af te bakenen voor de verdere uitwerking.

---

## 2\. Aanleiding: RelatedPerson en zorgcontext

### Het probleem

Voor de aanpassing van de RelatedPerson is het nodig om de **zorgcontext** (personen om de patiënt heen) te communiceren. Dit is nodig omdat:

- De relatie van de RelatedPerson, in tegenstelling tot de relatie van de behandelaar (Practitioner), **gevoelig** is  
- Deze relatie **wijzigt over tijd** (bijv. scheiding, overlijden, wijziging in rol)

### Huidige situatie

In het huidige Koppeltaal model wordt de relatie van gebruikers (Patient, Practitioner én RelatedPerson) **enkel tijdens de launch** uitgesproken. Voor RelatedPersons heeft dit specifieke nadelen:

1. **Snapshot-karakter**: De launch geeft een momentopname van de relatie  
2. **Geen synchronisatie**: Wijzigingen kunnen zonder nieuwe launch niet worden uitgewisseld  
3. **Verdwijnende relaties**: Vooral problematisch wanneer relaties eindigen \- dit kan niet worden gecommuniceerd

### Praktijkprobleem

In principe zou het snapshot-karakter geen issue moeten zijn indien module applicaties **enkel toegang verstrekken op basis van een launch**.

Helaas is de praktijk anders: module applicaties geven ook **buiten de launch** toegang. Dit betekent dat verouderde relatie-informatie kan leiden tot onterechte toegang of juist onterechte weigering.

---

## 3\. CareTeam en Autorisatie

### CareTeam als zorgcontext

Het CareTeam is **niet** het autorisatiemodel zelf, maar beschrijft de **zorgcontext** van een patiënt:

- Welke Practitioners zijn betrokken  
- Welke RelatedPersons zijn betrokken  
- In welke rol zijn zij betrokken

Deze informatie vormt één van de startpunten voor het autorisatiemodel, omdat op basis van deze rollen de rechten worden bepaald.

Zie voor de volledige beschrijving: [CareTeam en Autorisatie: de relatie](https://vzvznl.github.io/Koppeltaal-2.0-FHIR/autorisaties-careteam.html#careteam-en-autorisatie-de-relatie).

### Relatie met autorisatiematrix

Het CareTeam is onderdeel van de ontwikkeling van de autorisatiematrix. De relatie is als volgt:

```
CareTeam (Zorgcontext)
        │
        ▼
Autorisatiematrix (Rechten per rol)
        │
        ▼
FHIR Resources (Toegang)
```

---

## 4\. Scope voor RelatedPerson

### Belangrijke afbakening

De **volledige autorisatiematrix is NIET nodig** voor de RelatedPerson use case.

### Voorstel: 0.1 versie van de matrix

In plaats van te wachten op de volledige uitwerking van de autorisatiematrix, kunnen we werken met een **0.1 versie** van de matrix:

- Deze versie manifesteert zich **enkel in afspraken tussen leveranciers**  
- De afspraken worden niet technisch afgedwongen door de FHIR dienst  
- Leveranciers zijn zelf verantwoordelijk voor de implementatie van de autorisatie

Dit sluit aan bij het **transitiemodel** waarbij het datamodel en autorisatiemodel **INFORMATIEF** zijn voor applicaties die via SMART on FHIR Backend Services werken (zie `input/pagecontent/autorisaties-transitiemodel.md`).

---

## 5\. FHIR Profiel aanpassingen

### Benodigde aanpassingen

Er moeten aanpassingen gedaan worden aan het FHIR profiel om de rollen van de RelatedPerson op de juiste manier in te richten.

### Rollen voor RelatedPerson

De concrete rollen voor RelatedPerson moeten nog worden vastgesteld. Mogelijke rollen (ter discussie):

| Rol                         | Omschrijving                   | Bevoegdheden (indicatief)                                  |
|:----------------------------|:-------------------------------|:-----------------------------------------------------------|
| Naaste                      | Algemene naaste/verwant        | Meekijken, ondersteunen, communiceren                      |
| Mantelzorger                | Structurele zorgverlener       | Meekijken, uitvoeren (beperkt), ondersteunen, communiceren |
| Wettelijk vertegenwoordiger | Juridisch gemachtigd           | Meekijken, uitvoeren, namens patiënt handelen              |
| Buddy                       | Ervaringsdeskundige begeleider | Meekijken, ondersteunen, communiceren                      |

**Let op:** Deze rollen zijn indicatief en moeten nog worden vastgesteld door de visiegroep en tech community.

### Profiel aanpassingen

Het `KT2_CareTeam` profiel moet zodanig worden aangepast dat rollen voor naasten in een CareTeam vastgelegd kunnen worden.

---

## 6\. Vervolgacties

Uit KPTSD-893 komen de volgende acties:

1. **Stel de rollen vast voor de behandelaar** en bijbehorende bevoegdheden  
2. **Stel de rollen vast voor de naaste** en bijbehorende bevoegdheden  
3. **Pas KT2\_CareTeam profiel aan** zodanig dat rollen voor naasten in een CareTeam vastgelegd kunnen worden  
4. **Lever een nieuw Koppeltaal profiel uit**  
5. **Bepaal de impact** op de bestaande topics, use-cases en architectuur besluiten

---

## 7\. Samenvatting

| Aspect | Scope |
| :---- | :---- |
| CareTeam | Beschrijft zorgcontext, startpunt voor autorisatie |
| RelatedPerson | Gevoelige relatie die wijzigt over tijd |
| Autorisatiematrix | 0.1 versie, enkel afspraken tussen leveranciers |
| FHIR profiel | Aanpassingen nodig voor rollen RelatedPerson |
| Afdwinging | Niet door FHIR dienst, leveranciers zelf verantwoordelijk |

---

## Referenties

- KPTSD-893 (JIRA)  
- `input/pagecontent/autorisaties-careteam.md`  
- `input/page content/autorisaties-transitiemodel.md`

Vervolg:

1. Uitzoeken/bevestigen  welke rollen  we nodig hebben om te voldoen aan de vraag die gesteld is vanuit de community  
2. Maak een mapping tussen de benodigde rollen en de rolcodes die snomed ter beschikking stelt?  
3. Beschrijf functioneel eenduidige hoe het CareTeam te gebruiken in de koppeltaal standaard   
   1. Voor alle rollen (Practitioner, RelatedPerson)  
4. Maak expliciet wat we bedoelen met de terminologie die we gebruiken in de bevoegdheden die we gebruiken in de tabel van de onderscheiden rollen. (kolom toevoegen met meekijken \= ….. , ondersteunen=...., etc.) 
