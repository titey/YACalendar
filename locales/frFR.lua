local L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:NewLocale("YACalendar", "frFR")
if not L then return end

L["monday"] = "lundi"
L["tuesday"] = "mardi"
L["wednesday"] = "mercredi"
L["thursday"] = "jeudi"
L["friday"] = "vendredi"
L["saturday"] = "samedi"
L["sunday"] = "dimanche"

L["january"] = "janvier"
L["february"] = "février"
L["march"] = "mars"
L["april"] = "avril"
L["may"] = "mai"
L["june"] = "juin"
L["july"] = "juillet"
L["august"] = "août"
L["september"] = "septembre"
L["october"] = "octobre"
L["november"] = "novembre"
L["december"] = "décembre"

L["completeDate"] = "$7n $3n $8n $1n"
L["tinyDateTime"] = "$3n/$2n $4nh$5n"
L["eventDateTime"] = "$7n $3n $8n $1n $4n:$5n"

L["duration"] = "Durée : "
L["Created by:"] = "Créé par :"
L["Last update:"] = "Dernière mise à jour :"
L["Comment:"] = "Commentaire :"

L["coming"] = "Présent"
L["notcoming"] = "Absent"
L["uncertain"] = "Incertain"
L["comingcolon"] = "Présent :"
L["notcomingcolon"] = "Absent :"
L["uncertaincolon"] = "Incertain :"
L["participant"] = "participant"
L["participants"] = "participants"
L["participantsdetail"] = "$1n $2n ($3n, $4n, $5n)"
L["tank"] = "Tank"
L["heal"] = "Heal"
L["dd"] = "DPS"
L["errorraidcheckbutton"] = "C'est un événement de type raid, cochez une case de rôle"
L["okdeleteevent"] = "Êtes-vous sûr de vouloir supprimer l'événement \"$1n\" ?"

L["addevent"] = "Créer un événement"
L["delete"] = "Supprimer"

L["addeventwindowtitle"] = "Créer un nouvel événement"
L["eventname"] = "Nom"
L["eventdate"] = "Date\n\n(année, mois, jour)"
L["eventhourminute"] = "Heure/minute"
L["eventduration"] = "Durée"
L["eventcomment"] = "Commentaire"
L["eventraid"] = "Evénement avent./donj./raid"
L["eventplayers"] = "Joueurs"
L["eventtank"] = "Tanks"
L["eventheal"] = "Soigneurs"
L["eventdd"] = "DPS"
L["eventplayerscolon"] = "Joueurs :"
L["eventtankcolon"] = "Tanks :"
L["eventhealcolon"] = "Soigneurs :"
L["eventddcolon"] = "DPS :"
L["add"] = "Ajouter"
L["close"] = "Fermer"
L["baddate"] = "Il y a une erreur dans la date de l'événement"
L["mustbeafternow"] = "La date/heure indiquée doit être supérieure à maintenant"
L["namenotgood"] = "Le nom n'a pas la bonne longueur ou bien contient des caractères incorrects"
L["dateintegererror"] = "Une erreur s'est glissée dans les champs dates"
L["badraidmembers"] = "Une erreur s'est glissée dans la liste des membres du raid"

L["configuration"] = "Configuration"
L["titleconfig"] = "Configuration de Yet Another Calendar"
L["calendarname"] = "Nom du calendrier"
L["calendarsalt"] = "Clé d'identification"
L["save"] = "Sauvegarder"
L["okdeletecalendar"] = "Êtes-vous sûr de vouloir supprimer le calendrier \"$1n\" ?"
L["badnamesalt"] = "Caractère incorrect dans le nom/id du calendrier, ou vide, ou trop long (max. 30 caractères)"
