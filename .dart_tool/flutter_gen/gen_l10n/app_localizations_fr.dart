import 'app_localizations.dart';

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'CONTROLE';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get confirm => 'Confirmation';

  @override
  String get confirmLogout => 'Êtes-vous sûr de vouloir vous déconnecter?';

  @override
  String get no => 'Non';

  @override
  String get yes => 'Oui';

  @override
  String get login => 'Connexion';

  @override
  String get password => 'Mot de passe';

  @override
  String get userName => 'Nom d\'utilisateur';

  @override
  String get requiredField => 'Required field';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get cancel => 'Annuler';

  @override
  String get ok => 'Ok';

  @override
  String get edit => 'Modifier';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Galerie';

  @override
  String get iDontHaveAnAccount => 'Je n\'ai pas de compte';

  @override
  String get register => 'S\'inscrire';

  @override
  String get repeatPassword => 'Répéter le mot de passe';

  @override
  String get next => 'Suivant';

  @override
  String get passwordDontMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom de famille';

  @override
  String get back => 'Retour';

  @override
  String get save => 'Enregistrer';

  @override
  String get email => 'Email';

  @override
  String get inputEmail => 'Votre Email';

  @override
  String get validate => 'Valider';

  @override
  String get map => 'Carte';

  @override
  String get list => 'Liste';

  @override
  String get editEmail => 'Modifier l\'email';

  @override
  String get editInfo => 'Modifier les informations';

  @override
  String get profile => 'Profil';

  @override
  String get personalInfo => 'Informations personnelles';

  @override
  String get tapToVerifyYourEmail => 'Appuyez pour valider votre e-mail';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get oldPassword => 'Ancien mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get retypePassword => 'resaisie le mot de passe';

  @override
  String get passwordChanged => 'Le mot de passe a été changé avec succès';

  @override
  String get forgotPassword => 'Mot de passe oublié';

  @override
  String get recoverPassword => 'Récupérer mot de passe';

  @override
  String get inputUsername => 'Entrez le nom d\'utilisateur';

  @override
  String get usernameNotFound => 'Nom d\'utilisateur introuvable';

  @override
  String get address => 'Adresse';

  @override
  String get promotions => 'Promotions';

  @override
  String get filter => 'Filtrer';

  @override
  String get promotionEnds => 'Se termine le:';

  @override
  String get promotionStarted => 'De';

  @override
  String get deliveryAvailable => 'Livraison disponible';

  @override
  String get noMedia => 'Aucun média';

  @override
  String get couldNotLoadVideo => 'La vidéo n\'a pas pu être chargée';

  @override
  String get couldNotLoadData => 'Les données n\'ont pas pu être chargées';

  @override
  String get usePhoneInstead => 'Utiliser le numéro de téléphone';

  @override
  String get useEmailInstead => 'Utiliser l\'email';

  @override
  String get phoneVerificationFailedTitle => 'Erreur de vérification';

  @override
  String get phoneVerificationFailedText => 'Désolé, nous n\'avons pas pu vérifier votre numéro de téléphone';

  @override
  String get invalidCodeTitle => 'Code invalide';

  @override
  String get invalidCodeText => 'Code invalide';

  @override
  String get invalidValue => 'Code invalide';

  @override
  String get phoneNumberUpdated => 'Numéro de téléphone mis à jour avec succès';

  @override
  String get invalidEmail => 'Email invalide';

  @override
  String get emailUpdated => 'Email mis à jour avec succès';

  @override
  String get notFound => '404 Non trouvé';

  @override
  String get da => 'DZD';

  @override
  String maxValue(Object value) {
    return 'La valeur doit être inférieure ou égale à $value}';
  }

  @override
  String minValue(Object value) {
    return 'La valeur doit être supérieure ou égale à $value';
  }

  @override
  String get showMore => 'Charger plus';

  @override
  String get categories => 'Catégories';

  @override
  String get selectAll => 'Selectioner tout';

  @override
  String get range => 'Plage';

  @override
  String get favorites => 'Favoris';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get favoritesWillAppearHere => 'Les magasins préférés apparaîtront ici';

  @override
  String get addedToFavorites => 'Ajouté aux favoris';

  @override
  String get removedFromFavorites => 'Supprimé des favoris';

  @override
  String selectedCount(Object value) {
    return '$value sélectionné(es)';
  }

  @override
  String get editPhoneNumber => 'Modifier le numéro de téléphone';

  @override
  String get send => 'Envoyer';

  @override
  String get stores => 'Magasins';

  @override
  String get changeLanguage => 'Changer la langue';

  @override
  String get termsAndConditions => 'Termes et conditions';

  @override
  String get search => 'Recherche';

  @override
  String get searchStoreByName => 'Nom du magasin';

  @override
  String get noStores => 'Pas de magasins';

  @override
  String get promotionsAndOffers => 'OFFRES & PROMOTIONS';

  @override
  String get toTime => 'à';

  @override
  String get customerName => 'Nom du client';

  @override
  String get newCustomer => 'Nouveau client';

  @override
  String get editCustomer => 'Modifier le client';

  @override
  String get street => 'Rue';

  @override
  String get city => 'Cité';

  @override
  String get state => 'Etat';

  @override
  String get country => 'Pays';

  @override
  String get postalCode => 'Code postal';

  @override
  String get coordinates => 'Coordonnées';

  @override
  String get newAgentType => 'Nouveau agent type';

  @override
  String get agentTypeName => 'Nom d\'Agent type';

  @override
  String get agentTypeDescription => ' description d\'agent type ';

  @override
  String get newSite => 'Nouveau site';

  @override
  String get siteName => 'Nom du site ';

  @override
  String get startTime => 'De';

  @override
  String get endttime => 'A';

  @override
  String get newAgent => 'Nouveau agent';

  @override
  String get agentType => 'Agent-type ';

  @override
  String get socialSecurity => 'Sécurité sociale';

  @override
  String get value => 'Valeur';

  @override
  String get expiryDate => 'Date d\'expiration';

  @override
  String get language => 'Langue';

  @override
  String get newContract => 'Nouveau contrat';

  @override
  String get hoursPerMonth => 'Heures par mois';

  @override
  String get startDate => 'Date de début';

  @override
  String get endDate => 'Date de fin';

  @override
  String get selectAgentTypes => 'selectionner agent types';

  @override
  String get selectAgentType => 'selectionner agent type';

  @override
  String get addContacts => 'Ajouter des contacts';

  @override
  String get contactName => 'Contact';

  @override
  String get contactValue => 'Valeur du contact';

  @override
  String get contactNameEx => 'Website, email...';

  @override
  String get newContact => 'Nouveau contact';

  @override
  String get newHoliday => 'Nouveau Congé';

  @override
  String get newPlanification => 'Nouvelle planification';

  @override
  String get planificationStatus => 'Statue de la planification';

  @override
  String get selectThePlanificationStatus => 'selectionner statue de la planification';

  @override
  String get invalidDateRange => 'Plage de dates invalide!';

  @override
  String get selectSite => 'selectionner un Site';

  @override
  String get addAgentType => 'Ajouter agent type';

  @override
  String get notes => 'Notes';

  @override
  String get selectAgent => 'Selectionner Agent';

  @override
  String get createdsuccssfully => 'Créé avec succès';

  @override
  String get genderMale => 'MALE';

  @override
  String get genderFemale => 'FEMELLE';

  @override
  String get gender => 'Sexe';

  @override
  String get employmentType => 'Type d\'emploi';

  @override
  String get contractor => 'prestataire';

  @override
  String get employee => 'EMPLOYÉ/ÉE';

  @override
  String get agentStatus => 'Statue d\'Agent ';

  @override
  String get active => 'ACTIVE';

  @override
  String get selectCustomer => 'Selectionner un client';

  @override
  String get agentStatusActive => 'Active';

  @override
  String get agentStatusSuspended => 'Suspendu/e';

  @override
  String get agentEmploymentTypeContractor => 'prestataire';

  @override
  String get agentEmploymentTypeEmployee => 'Employé/ée';

  @override
  String get addAgentPlanificationRelation => 'Ajouter des agents';

  @override
  String get agent => 'Agent';

  @override
  String get planificationStatusNew => 'Nouvelle';

  @override
  String get planificationStatusDone => 'Faite';

  @override
  String get planificationStatusCanceled => 'Annuler';

  @override
  String get changeRole => 'Changer le role';

  @override
  String get delete => 'Supprimer';

  @override
  String get customerList => 'Liste des clients';

  @override
  String get customerDetails => 'les details du client';

  @override
  String get siteList => 'Liste des sites';

  @override
  String get agentList => 'Liste des agents';

  @override
  String get customer => 'Client';

  @override
  String get name => 'Nom';

  @override
  String get agentDetails => 'Details de l\'agent';

  @override
  String get siteDetails => 'Details du site';

  @override
  String get contractDetails => 'Details du contrat';

  @override
  String get noContract => 'Pas de contrat';

  @override
  String get planificationList => 'Liste des Planifications';

  @override
  String get planificationDetails => 'Details de la planification ';

  @override
  String get addPlanification => 'Ajouter une planification';

  @override
  String get selectACustomerFirst => 'Veuillez selectionner un client d\'abord';

  @override
  String get site => 'Site';

  @override
  String get agentName => 'le nom d\'agent';

  @override
  String get start => 'Démarrer';

  @override
  String get agents => 'Agents';

  @override
  String get customers => 'Les clients';

  @override
  String get agentTypeList => 'Liste de type agent';

  @override
  String get agentTypes => 'Types d\'agents';

  @override
  String get addAgent => 'Ajouter un agent';

  @override
  String get addCustomer => 'Ajouter le client';

  @override
  String get previous => 'Précédent';

  @override
  String get submit => 'soumettre';

  @override
  String get agentInformations => 'Informations d\'agent';

  @override
  String get accountDetails => 'Détails du compte';

  @override
  String get employementDetails => 'Détails de l\'emploi';

  @override
  String get selectAgentTypesFirst => 'Sélectionnez d\'abord un type d\'agent';

  @override
  String get addAContact => 'Ajouter un contact d\'abord';

  @override
  String get siteInformations => 'Informations sur le site';

  @override
  String get contacts => 'Contacts';

  @override
  String get addSite => 'Ajouter un site';

  @override
  String get customerSites => 'Sites du client';

  @override
  String get noSite => 'Pas de site';

  @override
  String get holidaysHistory => 'historique des congés';

  @override
  String get savedSuccessfully => 'Enregistrer avec succès';

  @override
  String get noHolidays => 'Pas de congés';

  @override
  String get editAgentType => 'Modifier le type d\'agent';

  @override
  String get editAgent => 'Modifier l\'agent';

  @override
  String get done => 'Fait';

  @override
  String get editSite => 'Modifier le site';

  @override
  String get editContract => 'Modifier le contrat';

  @override
  String get editHolidays => 'Modifier les congés';

  @override
  String get pleaseConfirm => ' Veuillez confirmer ';

  @override
  String get confirmDelete => 'Êtes-vous sûr de bien vouloir supprimer cet élément?';

  @override
  String get createAnIntervention => 'Créer une intervention';

  @override
  String get isProCardRequired => 'une carte professionnelle, est-elle obligatoire ?';

  @override
  String get editPlanification => 'Modifier la planification';

  @override
  String get selectAnAgent => 'selectionner un agent';

  @override
  String get agentNoGeoPoint => 'cet agent n\'a pas de geopoint';

  @override
  String get sentAt => 'envoyé à';

  @override
  String get noCustomer => 'pas de clients';

  @override
  String get receivedAt => 'reçu à';

  @override
  String get selectMonth => 'selectionner un mois';

  @override
  String get lastKnownPosition => 'dernière position reçu';

  @override
  String get proCardNeeded => 'il faut une carte professionnelle';

  @override
  String get noAgent => 'pas d\'agents';

  @override
  String get noAgentType => 'pas de agent types';

  @override
  String get workedHours => 'Heures travaillées';

  @override
  String get percentage => 'pourcentage';

  @override
  String get reload => 'rafraichir';

  @override
  String get workHours => 'Heures de travail ';

  @override
  String get siteWorkHours => 'Site\'s Work hours';

  @override
  String get cannotEditPlanification => 'Vous pouvez pas modifier cette planification';

  @override
  String get archive => 'archiver';

  @override
  String get confirmCancelPlanification => 'Voulez-vous vraiment annuler cette planification?';

  @override
  String get confirmArchivePlanification => 'Voulez-vous vraiment archiver cette planification?';

  @override
  String get planificationCanceled => 'Planification annulée avec succès';

  @override
  String get planificationArchieved => 'Planification archivée avec succès';

  @override
  String get resetPassword => 'réinitialiser le mot de passe';

  @override
  String get general => 'General';

  @override
  String get dateOfBirth => 'Date Of Birth';

  @override
  String get cardId => 'Id Card';

  @override
  String get frontImageUrl => 'Front image url';

  @override
  String get backImageUrl => 'Back image url';

  @override
  String get idCardInfo => 'Id card info';

  @override
  String get updatedSuccessfully => 'Updated successfully';

  @override
  String get addFileTitle => 'Pick a file';

  @override
  String get editFileName => 'Edit file name';

  @override
  String get newAssistant => 'New assistant';

  @override
  String get credentails => 'Credentails';

  @override
  String get assistantList => 'Assistants';

  @override
  String get idCard => 'Id Card';

  @override
  String get fileList => 'Files';
}
