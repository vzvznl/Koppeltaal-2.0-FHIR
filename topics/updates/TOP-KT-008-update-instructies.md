# TOP-KT-008 — update-instructies t.b.v. TOP-KT-028

| Veld | Waarde |
| --- | --- |
| Topic | TOP-KT-008 — Beveiliging aspecten |
| Bron-PDF | topics/KTSA-TOP-KT-008 - Beveiliging aspecten-140726-142408.pdf |
| Datum | 2026-07-14 |
| Status | concept |

## Aanleiding

TOP-KT-008 is het verzameltopic van de beveiligingsaspecten van Koppeltaal (de eigen status-notitie zegt: "niet compleet nog uitputtend"). Dit document is een **impact-onderzoek**: heeft het opschoningsontwerp van TOP-KT-028 — Opschoning patiëntgegevens impact op de beveiligingsaspecten, conform AVG en NEN 7510/7513? De huidige inhoud (v1.02, 1 okt 2025) betreft vrijwel uitsluitend transport- en applicatiebeveiliging: HTTPS, sleutelbeheer/JWKS, access control, JWT, autorisatielijsten, inputvalidatie, CORS en security headers. Gegevenslifecycle, bewaartermijnen en logging-hygiëne ontbreken als aspect.

**Conclusie van het onderzoek: beperkte impact.** Geen van de bestaande beveiligingsmaatregelen wijzigt door TOP-KT-028; de opschoon-flow gebruikt reguliere FHIR-interacties over dezelfde beveiligde kanalen. Wel maakt TOP-KT-028 twee aspecten relevant die in dit verzameltopic thuishoren maar er nu niet in staan — bewaartermijnen/gegevenslifecycle en logging zonder PII — plus één privacy-aandachtspunt dat afhangt van een openstaand besluit. De onderbouwing per aspect staat hieronder; de voorgestelde aanvullingen onder [Wijzigingen](#wijzigingen).

## Impact-analyse per aspect

### A1 — Bewaartermijnen: max. 2 jaar PII vs. min. 5 jaar audit-logging

**Bevinding: beperkte impact — aanvulling nodig, geen conflict.** TOP-KT-028 hanteert gescheiden termijnen: persoonsgegevens maximaal 2 jaar vanaf de laatste betrokkenheid van de patiënt (`last-patient-engagement`), AuditEvents minimaal 5 jaar (NEN 7513). Die combinatie is alleen houdbaar doordat de AuditEvents géén PII bevatten (zie A2) — anders zou de logging-termijn de PII-termijn feitelijk oprekken. Het ontwerp lost dat correct op. Voor TOP-KT-008 betekent dit: de gecontroleerde, auditeerbare verwijdering is zélf een beveiligings-/privacymaatregel (opslagbeperking, AVG art. 5 lid 1 onder e; beheerste verwijderprocessen conform NEN 7510), en hoort daarom als aspect in dit verzameltopic — als korte samenvatting met verwijzing, niet als duplicaat van TOP-KT-028. Zie W1.

### A2 — Scheiding PII en logging

**Bevinding: beperkte impact — principe expliciet vastleggen.** Het ontwerp scheidt PII en logging strikt: AuditEvents zijn immutable, bevatten geen demografie en geen vrije-tekstvelden — uitsluitend coded data en technische, pseudonieme referenties (zoals een Patient-UUID). De app-leesbare delete-AuditEvents zijn bewust vrij van vrije tekst zodat er geen PII kan lekken; de noodrem-reden (`Task.statusReason`) is coded en leeft op de Task, die met de erase mee verdwijnt. Dit sluit aan op NEN 7513 (logging als zelfstandig, integer record) en is een generiek beveiligingsprincipe dat breder geldt dan de opschoning alleen. TOP-KT-008 benoemt dit principe nu nergens. Zie W2.

### A3 — Pseudonieme referenties in AuditEvents ná de erase

**Bevinding: beperkte impact — juridische duiding vastleggen; ontwerp hoeft niet te wijzigen.** Na de definitieve verwijdering ontsluiten de achterblijvende referenties in de AuditEvents bínnen de Koppeltaalvoorziening geen herleidbare gegevens meer. Ze gelden echter **niet als volledig geanonimiseerd** maar als gepseudonimiseerd (AVG art. 4 lid 5; overweging 26): zolang herleiding elders mogelijk is — het bronsysteem/ECD kent dezelfde technische identifiers — blijft de bewaarde logging een verwerking van persoonsgegevens. Gevolg: de beveiligingseisen (AVG art. 32) en het toegangsregime blijven onverkort op de AuditEvents van toepassing — read-only voor applicaties (KT2-beleid), leesbaarheid van de delete-events uitsluitend via de `kt2-delete-flow`-marker binnen het eigen DPA-domein, en de 5-jaarstermijn als bewaargrondslag (NEN 7513). Dit moet in TOP-KT-008 worden benoemd zodat de logging niet ten onrechte als "anoniem, dus vrij" wordt behandeld. Zie W2.

### A4 — Rechten van betrokkenen (AVG art. 15 en 17)

**Bevinding: geen impact op TOP-KT-008 — verwijzing volstaat.** TOP-KT-028 belegt dit procesmatig: inzage (art. 15) wordt gefaciliteerd zolang de data aanwezig is, zonder dat de bewaartermijn herstart (inzage is geen wijziging), in de praktijk via het EPD; het recht om vergeten te worden (art. 17) is een aparte procedure met eigen toetsing en valt buiten het opschoon-topic. De rolverdeling is vastgelegd (Koppeltaalvoorziening = verwerker, ECD = verwerkingsverantwoordelijke en dossierhouder). TOP-KT-008 normeert techniek, geen rechtenprocessen; er is geen bestaande sectie die hiermee in strijd is of aanpassing behoeft. Een verwijzing naar TOP-KT-028 onder de gerelateerde onderwerpen volstaat. Zie W3.

### A5 — Domein-brede leesbaarheid van de opschoon-flow (AVG art. 19; TOP-KT-028 discussiepunt 1)

**Bevinding: aandachtspunt — opname afhankelijk van open besluit.** Elke deelnemende applicatie binnen het DPA-domein kan de hele opschoon-flow lezen: welke patiënten (pseudonieme UUID's, coded data, geen demografie) voor verwijdering zijn aangekondigd en welke statusovergangen plaatsvinden. Dat is een bewuste ontwerpkeuze (transparantie en een eenvoudig, FHIR-native model), maar het betekent wél dat applicaties opschoon-metadata zien van patiënten waar ze inhoudelijk niets mee doen. AVG art. 19 (notificatieplicht aan ontvangers) wijst richting footprint-based versmalling als mogelijke v2; TOP-KT-028 discussiepunt 1 legt dit ter bevestiging bij privacy. Zolang dat besluit openstaat, is dit een te benoemen restrisico/aandachtspunt in TOP-KT-008 — geen reden tot ontwerpwijziging. Zie W4.

### A6 — Bestaande maatregelen (HTTPS, sleutelbeheer, JWT, inputvalidatie, CORS, security headers)

**Bevinding: geen impact.** De opschoon-flow introduceert geen nieuwe kanalen, endpoints of authenticatiemechanismen: aankondiging en respons lopen via reguliere FHIR-interacties (`GET`/search, `PUT` met `If-Match`, standaard `Subscription`) over de bestaande, reeds genormeerde transportbeveiliging. De autorisatie-uitzondering (de server-owned `kt2-delete-flow`-marker) is belegd in TOP-KT-005 (zie de update-instructies aldaar) en hoeft in TOP-KT-008 niet te worden herhaald.

## Wijzigingen

### W1 — "Toepassing en restricties" → nieuwe subsectie "Bewaartermijnen en gegevenslifecycle" (na "Access Control (toegangscontrole)")

- **Actie**: toevoegen
- **Voorstel**:

  > #### Bewaartermijnen en gegevenslifecycle
  >
  > Koppeltaal hanteert gescheiden bewaartermijnen voor persoonsgegevens en logging (opslagbeperking, AVG art. 5 lid 1 onder e; NEN 7513):
  >
  > - Persoonsgegevens (PII) worden maximaal 2 jaar bewaard, gerekend vanaf de laatste betrokkenheid van de patiënt. De gecontroleerde verwijdering — aankondiging per applicatie, grace period, noodrem en definitieve erase — is beschreven in [TOP-KT-028 - Opschoning patiëntgegevens].
  > - AuditEvents (NEN 7513-logging) worden minimaal 5 jaar bewaard en zijn uitgezonderd van de verwijdering. Dit conflicteert niet met de PII-termijn, omdat AuditEvents geen persoonsgegevens in demografische zin bevatten (zie "Logging zonder PII").
  > - De definitieve verwijdering is een harde erase: alle versies worden gewist en een latere GET geeft 404. Het `destroy`-AuditEvent vormt het blijvende, aantoonbare bewijs van de vernietiging (verantwoordingsplicht, AVG art. 5 lid 2).
  >
  > Het ECD blijft als dossierhouder verantwoordelijk voor de eigen (WGBO-)bewaarplicht en voor het tijdig veiligstellen van data; de Koppeltaalvoorziening is verwerker en initieert en faciliteert de opschoning.

- **Motivatie**: zie A1. Gecontroleerde verwijdering is een beveiligings-/privacymaatregel die in het verzameltopic hoort; de tekst vat samen en verwijst, zodat TOP-KT-028 de enige normatieve bron blijft.

### W2 — "Toepassing en restricties" → nieuwe subsectie "Logging zonder PII (pseudonimisering)" (direct na W1)

- **Actie**: toevoegen
- **Voorstel**:

  > #### Logging zonder PII (pseudonimisering)
  >
  > AuditEvents zijn immutable en bevatten geen persoonsgegevens in demografische zin: geen namen of contactgegevens en geen vrije-tekstvelden — uitsluitend coded data en technische, pseudonieme referenties (zoals een Patient-UUID). Dit geldt in het bijzonder voor de AuditEvents van het opschoonproces, die de verwijdering overleven.
  >
  > Na de definitieve verwijdering van de patiëntgegevens ontsluiten de achterblijvende referenties binnen de Koppeltaalvoorziening geen herleidbare gegevens meer. Zij gelden echter niet als volledig geanonimiseerd, maar als gepseudonimiseerd (AVG art. 4 lid 5): zolang herleiding elders mogelijk is (bijvoorbeeld in het bronsysteem), blijft de bewaarde logging een verwerking van persoonsgegevens. De beveiligingseisen van dit topic en het toegangsregime van [TOP-KT-005 - Toegangsbeheersing] blijven daarom onverkort op AuditEvents van toepassing: AuditEvents zijn voor applicaties read-only en de opschoon-AuditEvents zijn uitsluitend leesbaar voor deelnemende applicaties binnen hetzelfde DPA-domein.

- **Motivatie**: zie A2 en A3. Legt het scheidingsprincipe en de juridische status van de post-erase logging vast, zodat de 5-jaars bewaring niet als "anonieme data" buiten het beveiligingsregime valt.

### W3 — "Links naar gerelateerde onderwerpen"

- **Actie**: toevoegen (twee regels aan de bestaande lijst)
- **Voorstel**:

  > [TOP-KT-028 - Opschoning patiëntgegevens]
  >
  > [TOP-KT-011 - Logging en tracing]

- **Motivatie**: zie A4. TOP-KT-028 belegt de bewaartermijnen, het verwijderproces en de rechten van betrokkenen; TOP-KT-011 specificeert de AuditEvents waarnaar W1/W2 verwijzen. Daarmee is de betrokkenenrechten-kant (art. 15/17) via verwijzing gedekt zonder dit topic uit te breiden met rechtenprocessen.

### W4 — "Toepassing en restricties" → alinea "Aandachtspunt: domein-transparantie van de opschoon-flow" (onderaan de subsectie van W1) — *afhankelijk van besluit TOP-KT-028 discussiepunt 1*

- **Actie**: toevoegen
- **Voorstel**:

  > **Aandachtspunt — domein-transparantie.** De opschoon-flow is domein-breed leesbaar: elke deelnemende applicatie binnen het DPA-domein kan zien welke patiënten (pseudonieme referenties, coded data, geen demografie) voor verwijdering zijn aangekondigd en welke statusovergangen plaatsvinden. Dit is een bewuste ontwerpkeuze van [TOP-KT-028 - Opschoning patiëntgegevens]; een footprint-based versmalling (alleen zichtbaar voor applicaties die de patiënt daadwerkelijk kennen, vgl. AVG art. 19) is als mogelijke doorontwikkeling benoemd.

- **Motivatie**: zie A5. Zolang discussiepunt 1 openstaat, moet de tekst het aandachtspunt eerlijk benoemen; wordt tot footprint-versmalling besloten, dan vervalt of wijzigt deze alinea.

## Verwijzingen

- `topics/TOP-KT-028-opschoning-patientgegevens.md` — besloten ontwerp (v0.3, 14 jul 2026); m.n. "Uitgangspunten" (logging/PII-scheiding), "Termijnen", "Rechten van betrokkenen & contractbeëindiging", eisen 12–14 en 16, discussiepunt 1
- `input/pagecontent/opschoning-patient-data.md` — IG-pagina, uitgangspunten en oplossingsrichting
- `input/pagecontent/memo-wijzigingen-topic11.md` — §3.8 (opschoning-lifecycle-AuditEvents: geen PII, overleven de erase)
- `topics/updates/TOP-KT-005-update-instructies.md` — de autorisatie-uitzondering (`kt2-delete-flow`) die in Topic 05 wordt belegd
- AVG art. 4 lid 5, art. 5 lid 1 onder c/e en lid 2, art. 15, 17, 19, 32; NEN 7510; NEN 7513; WGBO

## Open punten

1. **Afhankelijk van besluit TOP-KT-028 discussiepunt 1** (domein-transparantie vs. footprint, bevestiging door privacy): W4 en de formulering "domein-breed" in W2. Bij een besluit tot footprint-versmalling vervalt W4 en wordt W2 aangepast.
2. **Bewaartermijn audit-logging bevestigen.** TOP-KT-028 noemt "min. 5 jaar" met de kanttekening dat dit nog tegen NEN 7513 bevestigd moet worden. De termijn in W1 volgt dat besluit.
3. **Geen actuele md-versie van dit topic beschikbaar**; het onderzoek is uitgevoerd op de bron-PDF (v1.02, 1 okt 2025, 4 pagina's — volledig leesbaar). Er is ook een Confluence-Word-export in de repo-root (`TOP-KT-008+-+Beveiliging+aspecten.doc`); die is niet apart geverifieerd.
4. **Eisen-sectie ontbreekt in TOP-KT-008.** Het topic kent geen genummerde eisen; de voorstellen zijn daarom als beschrijvende tekst onder "Toepassing en restricties" geformuleerd, in de stijl van de bestaande subsecties. Wil de redactie normatieve eisen (MOET/SHOULD), dan horen die in TOP-KT-028/TOP-KT-005 thuis — daar staan ze al.
