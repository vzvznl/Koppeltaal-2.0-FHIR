**Document:** Koppeltaal 2.0 - CareTeam Autorisaties
**Referentie:** [CareTeam en Autorisaties](care-context-careteam.html)

---

### Feedback Leverancier B

#### 1. Rol van RelatedPerson voor autorisatie

##### Opmerking
> *"Voor autorisatie moeten alle betrokkenen (incl. relatedPersons) met hun correcte rol in het Careteam staan."* ([Basisprincipes](care-context-careteam.html#basisprincipes))

Betekent dit dat de rol v/d relatedPerson in de relatedPerson resource niet gebruikt gaat worden voor autorisatie? In dat geval kan daar de verplichting van het relationship element afgehaald worden.

##### Antwoord
Je zegt het correct, het gaat (vooralsnog) niet gebruikt worden voor autorisatie. Niet alle velden worden gebruikt voor autorisatie, of daarmee het veld ook moet verdwijnen gaat een beetje ver 🙃.

---

#### 2. Task.owner en het relevante CareTeam

##### Opmerking
> *"Task.owner moet lid zijn van het relevante CareTeam"* ([Basisprincipes](care-context-careteam.html#basisprincipes))

Vragen:
- Wat is het "relevante" Careteam?
- Betekent dit dat de cliënt participant moet zijn in z'n eigen Careteam?
- In onze applicatie is de cliënt geen member van z'n Zorgteam

##### Antwoord
Deze zinsnede lijdt een beetje onder de beslissing meerdere CareTeams toe te staan. Dit wordt aangepast naar meervoudigheid.

De cliënt moet als CareTeam.subject geregistreerd staan; de rol met zichzelf is daarmee duidelijk.

Het concept van een 'Zorgteam' in jullie systeem kan afwijken van de definitie in Koppeltaal. In Koppeltaal wordt gekozen voor Type 2: Patiënt-specifieke CareTeams. Indien jullie Type 1 gebruiken is dat geen probleem voor de communicatie met Koppeltaal.

---

#### 3. Task.requester en CareTeam lidmaatschap

##### Opmerking
> *"Task.requester moet lid zijn van het relevante CareTeam"* ([Basisprincipes](care-context-careteam.html#basisprincipes))

Dit is in tegenspraak met de scope: *"administratieve medewerkers die taken klaarzetten hoeven niet in het CareTeam te staan als verder geen deelnemer zijn in het zorgproces."* ([Scope van het CareTeam](care-context-careteam.html#basisprincipes))

##### Antwoord
Naar mijn inzicht niet in tegenspraak. In dat geval zijn administratieve medewerkers geen Task.requester. Let wel dat in jullie applicatie meer rollen en rechten kunnen bestaan dan in Koppeltaal zich manifesteren. Koppeltaal gaat over de informatie die we met elkaar uitwisselen, niet de interne staat van jullie systeem.

---

#### 4. CareTeam als Task.owner

##### Opmerking
> *"Een CareTeam kan niet direct Task.owner zijn"* ([Besluiten en Richtlijnen](care-context-careteam.html#besluiten-en-richtlijnen))

Hoewel ik het hiermee eens ben, is dit in tegenspraak met de beschrijving van Task level CareTeams.

##### Antwoord
Leverancier A had dezelfde opmerking. Dit is inmiddels aangepast in het document, zie het [changelog](care-context-careteam.html#changelog).

---

#### 5. Validatieregel Task.requester

##### Opmerking
> *Validatieregel: "Als Task.requester is ingevuld MOET deze persoon lid zijn van een CareTeam van Task.for (patient)"* ([Validatieregels](care-context-careteam.html#validatieregels))

Dit is in tegenspraak met de scope over administratieve medewerkers. Deze regel komt op verschillende plaatsen terug en is in strijd met de uitgangspunten: Een administratief medewerker die een taak klaarzet voor de cliënt (als Task.requester) heeft niet automatisch toegang tot de taak. Deze medewerker heeft alleen toegang als hij lid is van het (een) Careteam met een rol die toegang geeft. Daarom zal de aanvrager niet automatisch lid worden van het Careteam maar alleen als toegang nodig is.

##### Antwoord
Zie [3. Task.requester en CareTeam lidmaatschap](#3-taskrequester-en-careteam-lidmaatschap).

---

#### 6. Rol "eerste relatie" in CareTeam

##### Opmerking
> *"Zoon heeft rol 'eerste relatie' in het CareTeam"* ([SMART on FHIR Launch en Autorisatie](care-context-careteam.html#smart-on-fhir-launch-en-autorisatie))

Rol "eerste relatie" is geen reden voor autorisatie en geen rol in RelatedPerson Authorization.

##### Antwoord
De RelatedPerson heeft nu in het profiel geen rol. Dit zou ter hoogte van de discussie rond de rollenmatrix kunnen veranderen. In principe is de rollenmatrix out of scope voor dit document.

---

#### 7. Overige punten

**Eens met de besluiten en richtlijnen** — Akkoord.

**Impact op KT2_CareTeam resource** — Er zijn op basis van de vragen een aantal dingen verduidelijkt en aangepast. Zie het [changelog](care-context-careteam.html#changelog) boven in de pagina.

---

### Feedback Leverancier A

#### 1. fhirUser key in HTI token

##### Opmerking
In de voorbeeld JSON representatie van een HTI token onder "[Launch door portaalapplicatie](care-context-careteam.html#smart-on-fhir-launch-en-autorisatie)" wordt `fhirUser` genoemd. Ik kan noch in de HTI documentatie noch in de Koppeltaal documentatie die de launch beschrijft, deze key terugvinden. Waar komt deze key vandaan en wat betekent deze key?

##### Antwoord
Dit komt van KoppelMij, het voorbeeld was verkeerd en is aangepast. 
Zie [changelog](care-context-careteam.html#changelog).

---

#### 2. CareTeam als Task.owner

##### Opmerking
Onder de [besluiten en richtlijnen](care-context-careteam.html#besluiten-en-richtlijnen) staat expliciet "Een CareTeam kan niet direct Task.owner zijn". Volgens mij hebben we aangegeven n.a.v. het leveranciers overleg, dat een Task.owner wat ons betreft wél naar een CareTeam mag wijzen, als zijnde het team van mensen dat verantwoordelijk is deze taak uit te voeren. Die use-case wordt op dit moment niet gebruikt, maar zouden we niet bij voorbaat willen afsluiten voor de toekomst.

##### Antwoord
Het issue met Task.owner = CareTeam is dat dan onduidelijk is wie de uitvoerder is en dat heeft ter hoogte van een ander project (OZO) tot wat migraine geleid. De beperking is verwijderd en er is aangegeven dat het een specifieke use case betreft. Zie [changelog](care-context-careteam.html#changelog).

---

#### 3. Algemene beoordeling

Leverancier A geeft aan dat het over het geheel genomen een goede en werkbare weergave is van de plannen die zijn geformuleerd.

---

