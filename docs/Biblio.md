[FG 2022-01-09] this comment should disapear as soon as possible

* Pardon, je ne comprends pas grand chose. Je m’attendais à ce que Cahal transpose les exigences philologiques en consignes programmables. Il ne s’agit absolument pas que cela prenne plus de temps, au contraire, normalement la chaîne de la réflexion doit rendre l’information de plus en plus digérée de tête en tête pour arriver à un informaticien idiot, et à la machine qui est encore plus idiote (la machine n’a pas de corps, donc pas d’expérience, donc pas de (bon) sens. Les médiévaux le voyait clairement : «ledit Pierre, par impatience, fragilité ou diminution de son corps et de sa Sensualité, est devenu tout ydiote».)
* Je ne vois pas dans quelle page de l’application telle ou telle chose doit sortir.
* «**parenthèse fermante virgule**» est beaucoup moins clair que «),»
* _In Hippocratis De fracturis_ n’est pas le meilleur exemple, on peut croire que _In_ est un introducteur bibliographique
* Le titre abrégé n’est pas connu dans les fichiers XML, il faut le donner dans une forme qu’un programme peut parser (~~pas Excel~~) pour alimenter la bas de données, cf. un début [galenus.csv](https://github.com/galenus-verbatim/verbapy/blob/main/docs/galenus.csv)
* De même, l’abréviation de l’éditeur n’est pas connue
* Le numéro de ligne n’est pas encore dans la base, un casse-tête, mais une solution sera trouvée
* Je n’ai trouvé qu’seul fichier avec des sections [tlg0057.tlg073.1st1K-grc2](https://github.com/OpenGreekAndLatin/First1KGreek/blob/master/data/tlg0057/tlg073/tlg0057.tlg073.1st1K-grc2.xml#L104), faut-il alourdir le modèle pour ce seul cas ?
* Est-ce que ces structures bibliographiques vont fonctionner aussi pour Kaibel, Helmreich, ou des lettres byzantines ?


# structure de données 
tlg0057.tlg100.1st1K-grc1.xml: tittle: De differentiis febrium, editor: Karl Gottlob Kühn, vol: 7, pages; 273-405, date:1830.

# affichage sur la page :
In Hippocratis De fracturis, 1.20 (18b.364 K) 
# export sur 3 ligne

* Galien, In Hippocratis De fracturis (In Hipp. Fract.), 1.20 (18b.364.2 K).


Galien **virgule** titre du traité en italiques **parenthèse ouvrante** abréviation du traité en italiques avec espace insécable **parenthèse fermante virgule** numéro de livre **point** numéro de chapitre **point** éventuel numéro de section **espace + parenthèse ouvrante** numéro de volume point numéro de page **point** numéro de ligne **espace insécable (&nbsp;)** K **parenthèse fermante point**


# CTS

* [FG 2022-01-09] Le ':' a un statut particulier dans la spécification des uri [rfc3986](https://www.rfc-editor.org/rfc/rfc3986#section-2.2), on ne peut pas l’utiliser comme séparateur pour une partie qui doit apparaître dans une url qui répond sur l’internet. Le ':' est strictement limité à http://. http://galenus-verbatim.huma-num.fr/verbatim/tlg0057.tlg100.1st1K-grc1.1.20


urn:cts:greekLit:tlg0057.tlg100.1st1K-grc1:1.20

# ref biblio 
C.G. **espace insécable (&nbsp;)** Kühn, Galeni Opera Omnia, vol. **espace insécable (&nbsp;)** numéro de volume,  Leipzig **espace insécable (&nbsp;)* : Car. Cnoblochii, date du volume.

Exemple: C.G. Kühn, Galeni Opera Omnia, vol. 18b, Leipzig : Car. Cnoblochii, 1830.

# citation 
C.G. espace insécable (&nbsp;) Kühn, Galeni Opera Omnia, vol. espace insécable (&nbsp;) numéro de volume,  Leipzig espace insécable (&nbsp;) : Car. Cnoblochii, date du volume.

Exemple: C.G. Kühn, Galeni Opera Omnia, vol. 18b, Leipzig : Car. Cnoblochii, 1830.
