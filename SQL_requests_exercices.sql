#=====================================
#======= Requêtage simple ============
#=====================================
#------ Requêtage simple ------

SELECT * FROM produit ORDER BY PrixUnit ASC LIMIT 10;

SELECT * FROM produit ORDER BY PrixUnit DESC LIMIT 3;

#------ Restriction ---------

SELECT * FROM client WHERE (client.Fax IS NULL OR client.Fax = '') AND client.Pays = 'France' AND client.Ville = 'Paris';

SELECT * FROM client WHERE client.Pays = 'France' OR client.Pays = 'Allemagne' OR client.Pays = 'Canada';

SELECT * FROM client WHERE client.Societe LIKE "%restaurant%";

#------- Projection ---------

SELECT Descriptionn FROM categorie;

SELECT Pays,Ville FROM client ORDER BY Pays ASC, Ville DESC;

SELECT Societe, Contact, Ville FROM fournisseur ORDER BY Ville;

SELECT UPPER(NomProd) AS Nom_du_produit  FROM produit WHERE NoFour = 8 AND PrixUnit BETWEEN 10 AND 100 ;

#=====================================
#======= Calculs et Fonctions ========
#=====================================
#------- Calculs arithmétiques -----------

SELECT dc.PrixUnit, dc.Remise, dc.Qte , (dc.PrixUnit * dc.Remise) AS mRemis , (dc.PrixUnit - (dc.PrixUnit * dc.Remise)) * dc.Qte AS buyPrice

FROM detailscommande AS dc 
WHERE dc.NoCom = 10251;

#------- Traitement conditionnel----------

SELECT prod.NomProd,IF(prod.Indisponible = 0 , "Produit Disponible","Produit Indisponible") AS Disponibility 
FROM produit AS prod;

#------- Fonctions sur chaînes de caractères----------

SELECT `codeCli`, REPLACE(`fonction`, 'Owner', 'Freelance'), LOWER(`societe`), CONCAT(adresse, " ", ville," ",codePostal," ",pays) AS adresseAuComplet, RIGHT(`codeCli`, 2) AS extrait 
FROM `client` 
WHERE `fonction` Like '%Manager%'

#------- Fonctions sur les dates--------

SELECT IF(DATE_FORMAT(DateCom,"%W") LIKE '%Saturday%' OR DATE_FORMAT(DateCom,"%W") LIKE '%Sunday%' ,"WEEKEND" ,DATE_FORMAT(DateCom,"%W")) AS DateCommande 
FROM commande AS cmd;

SELECT DATEDIFF(ALivAvant,DateCom) AS DateDiff, DATE_FORMAT(DATE_ADD(ALivAvant, INTERVAL 1 MONTH) , '%d-%m-%Y') AS ContactDate 
FROM commande;

#=======================================
#============ [Aggrégats] ==============
#=======================================

#-------- Dénombrements ----------

SELECT COUNT(*) AS salesManager_count FROM employe WHERE Fonction LIKE '%Sales Manager%';

SELECT COUNT(*) AS categorie_1_Count FROM produit WHERE CodeCateg = 1 AND (NoFour = 1 OR NoFour = 18 );

SELECT COUNT(DISTINCT PaysLiv) As Country FROM commande;

SELECT COUNT(*) AS AugustDeleveryCount FROM commande WHERE DATE_FORMAT(ALivAvant, "%M %Y") LIKE 'August 2006';


#-------- Calculs statistiques simples ----------

SELECT MIN(Port) AS minPort, MAX(Port) AS maxPort, AVG(Port) AS avgPort FROM commande WHERE CodeCli = 'QUICK';

SELECT NoMess,SUM(port) AS total_Port FROM commande WHERE NoMess = 1 UNION SELECT NoMess,SUM(port) AS total_Port FROM commande WHERE NoMess = 2 UNION SELECT NoMess,SUM(port) AS total_Port FROM commande WHERE NoMess = 3;

#-------- Agrégats selon attribut(s) ----------

SELECT Fonction, COUNT(Fonction) AS employe_Count FROM employe GROUP BY Fonction;

SELECT NoFour, COUNT(DISTINCT CodeCateg) AS categorie_count FROM produit GROUP BY NoFour;

SELECT NoFour, CodeCateg, AVG(PrixUnit) AS avg_price FROM produit GROUP BY NoFour,CodeCateg;

#-------- Restriction sur agrégats ----------

SELECT NoFour, COUNT(DISTINCT NomProd) AS product_count FROM produit GROUP BY NoFour HAVING COUNT(DISTINCT NomProd) = 1;

SELECT NoFour, COUNT(DISTINCT CodeCateg) AS categorie_count FROM produit GROUP BY NoFour HAVING COUNT(DISTINCT CodeCateg) = 1;

SELECT NoFour, NomProd , PrixUnit FROM produit GROUP BY NoFour HAVING PrixUnit > 50;

#=======================================
#============ [Jointures] ==============
#=======================================

#--------Jointures naturelles ----------

SELECT _p.NomProd,_f.* FROM fournisseur AS _f NATURAL JOIN produit AS _p WHERE _f.NoFour = _p.NoFour;

SELECT * FROM commande AS _cmd NATURAL JOIN client AS _c WHERE _cmd.CodeCli = _c.Codecli AND _c.Societe = 'Lazy K Kountry Store';

SELECT messager.NomMess AS Nom_Du_Messager ,COUNT(commande.NoCom) AS commande_count FROM commande NATURAL JOIN messager GROUP BY messager.NomMess

#--------Jointures internes ----------


SELECT _prd.NomProd ,_fr.* FROM fournisseur AS _fr 	INNER JOIN produit AS _prd ON _fr.NoFour = _prd.NoFour GROUP BY _prd.NomProd

SELECT * FROM Commande INNER JOIN Client ON Commande.CodeCli = Client.CodeCli WHERE Societe = "Lazy K Kountry Store";

SELECT NomMess, COUNT(*) FROM Commande INNER JOIN Messager ON Commande.NoMess = Messager.NoMess GROUP BY NomMess;

#--------Jointures externes-------------

SELECT NomProd, COUNT(DISTINCT NoCom) FROM Produit LEFT OUTER JOIN DetailsCommande ON Produit.RefProd = DetailsCommande.RefProd GROUP BY NomProd;

SELECT NomProd FROM Produit LEFT OUTER JOIN DetailsCommande ON Produit.RefProd = DetailsCommande.RefProd GROUP BY NomProd HAVING COUNT(DISTINCT NoCom)=0;

SELECT Nom, Prenom  FROM Employe LEFT OUTER JOIN Commande ON Employe.NoEmp = Commande.NoEmp  GROUP BY Nom, Prenom  HAVING COUNT(DISTINCT NoCom)=0;

#--------Jointures à la main------------

SELECT produit.NomProd, fournisseur.Societe 
FROM produit LEFT JOIN fournisseur 
ON produit.NoFour = fournisseur.NoFour;

SELECT client.Societe, commande.* 
FROM commande LEFT JOIN client 
ON client.Societe = 'Lazy K Kountry Store';

SELECT messager.NomMess,COUNT(commande.CodeCli) AS 'Nombre de Commandes'
FROM messager RIGHT JOIN commande 
ON messager.NoMess = commande.NoMess
GROUP BY messager.NomMess;

#=====================================
#==========Sous-requêtes==============
#=====================================

#-----------Sous-requêtes--------------

SELECT employe.Nom FROM employe
WHERE employe.NoEmp NOT IN (SELECT commande.NoEmp FROM commande);

SELECT produit.* FROM produit
WHERE produit.NoFour IN (SELECT fournisseur.NoFour FROM fournisseur WHERE fournisseur.Societe = "Ma Maison");

SELECT commande.* 
FROM commande 
WHERE commande.NoEmp IN 
						(	SELECT employe.NoEmp 
							FROM employe 
							WHERE employe.RendCompteA IN
														(	SELECT employe.NoEmp 
															FROM employe 
															WHERE employe.Nom = 'Buchanan' AND employe.Prenom = 'Steven'));

#-----------Opérateur EXISTS--------------

SELECT produit.* 
FROM produit 
WHERE NOT EXISTS (SELECT detailscommande.RefProd 
				  FROM detailscommande 
				  WHERE detailscommande.RefProd = produit.RefProd);

SELECT fournisseur.Societe
        FROM fournisseur
        WHERE EXISTS (SELECT * 
                    FROM produit, detailscommande, commande
                    WHERE produit.RefProd = detailscommande.RefProd
                    AND detailscommande.NoCom = commande.NoCom
                    AND PaysLiv = "France"
                    AND NoFour = fournisseur.NoFour)

SELECT fournisseur.Societe
    FROM fournisseur
    WHERE EXISTS 
        (SELECT * FROM produit, categorie 
         WHERE produit.NoFour = fournisseur.NoFour AND produit.CodeCateg = categorie.CodeCateg AND categorie.NomCateg = "drinks")
    		AND NOT EXISTS 
        	(SELECT * FROM produit, categorie 
        	 WHERE produit.NoFour = fournisseur.NoFour AND produit.CodeCateg = categorie.CodeCateg AND categorie.NomCateg <> "drinks")



#------------Intersection-------------

SELECT employe.Nom, employe.Prenom 
FROM employe 
WHERE employe.fonction LIKE '%representative%' 
INTERSECT (SELECT employe.Nom, employe.Prenom 
	FROM employe 
	WHERE employe.pays = "UK");

SELECT client.Societe,client.Pays
FROM client, commande, detailscommande, employe, produit, categorie
WHERE
client.Codecli = commande.CodeCli AND
commande.NoCom = detailscommande.NoCom AND
commande.NoEmp = employe.NoEmp AND
employe.Ville LIKE "%seattle%" AND
produit.RefProd = detailscommande.RefProd AND
categorie.CodeCateg = produit.CodeCateg AND
categorie.NomCateg = 'Desserts';

#------------Différence--------------

SELECT employe.Nom, employe.Prenom 
FROM employe 
WHERE employe.fonction LIKE '%representative%' 
EXCEPT (SELECT employe.Nom, employe.Prenom 
	FROM employe 
	WHERE employe.pays = "UK");
