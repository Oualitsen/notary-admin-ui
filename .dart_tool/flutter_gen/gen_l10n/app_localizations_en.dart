import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CONTROLE';

  @override
  String get logout => 'Logout';

  @override
  String get confirm => 'Confirm';

  @override
  String get confirmLogout => 'Are you sure you want to log out?';

  @override
  String get no => 'No';

  @override
  String get yes => 'yes';

  @override
  String get login => 'Login';

  @override
  String get password => 'Password';

  @override
  String get userName => 'User name';

  @override
  String get requiredField => 'Required field';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'ok';

  @override
  String get edit => 'Edit';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get iDontHaveAnAccount => 'I don\'t have an account';

  @override
  String get register => 'Register';

  @override
  String get repeatPassword => 'Repeat password';

  @override
  String get next => 'Next';

  @override
  String get passwordDontMatch => 'Passwords don\'t match';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get email => 'Email';

  @override
  String get inputEmail => 'Input Email';

  @override
  String get validate => 'Validate';

  @override
  String get map => 'Map';

  @override
  String get list => 'List';

  @override
  String get editEmail => 'Edit email';

  @override
  String get editInfo => 'Edit info';

  @override
  String get profile => 'Profile';

  @override
  String get personalInfo => 'Personal Info';

  @override
  String get tapToVerifyYourEmail => 'Tap to validate your email';

  @override
  String get changePassword => 'Change password';

  @override
  String get oldPassword => 'Old password';

  @override
  String get newPassword => 'New password';

  @override
  String get retypePassword => 'Retype password';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String get forgotPassword => 'Forgot password';

  @override
  String get recoverPassword => 'Recover password';

  @override
  String get inputUsername => 'Input username';

  @override
  String get usernameNotFound => 'Username not found';

  @override
  String get address => 'Address';

  @override
  String get promotions => 'Promotions';

  @override
  String get filter => 'Filter';

  @override
  String get promotionEnds => 'Ends on:';

  @override
  String get promotionStarted => 'Started';

  @override
  String get deliveryAvailable => 'Delivery available';

  @override
  String get noMedia => 'No media';

  @override
  String get couldNotLoadVideo => 'Sorry could not load video';

  @override
  String get couldNotLoadData => 'Could not load data';

  @override
  String get usePhoneInstead => 'Use phone number instead';

  @override
  String get useEmailInstead => 'Use email instead';

  @override
  String get phoneVerificationFailedTitle => 'Verification error';

  @override
  String get phoneVerificationFailedText => 'Sorry we were unable to verify your phone number';

  @override
  String get invalidCodeTitle => 'Invalid code';

  @override
  String get invalidCodeText => 'Invalid code';

  @override
  String get invalidValue => 'Invalid value';

  @override
  String get phoneNumberUpdated => 'Phone number updated successfully';

  @override
  String get invalidEmail => 'Invalid Email';

  @override
  String get emailUpdated => 'Email Updated successfully';

  @override
  String get notFound => '404 Not Found';

  @override
  String get da => 'DZD';

  @override
  String maxValue(Object value) {
    return 'Value must be lower than or equal $value';
  }

  @override
  String minValue(Object value) {
    return 'Value must be greater than or equal $value';
  }

  @override
  String get showMore => 'Show more';

  @override
  String get categories => 'Categories';

  @override
  String get selectAll => 'Select All';

  @override
  String get range => 'Range';

  @override
  String get favorites => 'Favorites';

  @override
  String get favoritesTitle => 'FavoriS';

  @override
  String get favoritesWillAppearHere => 'Favorites Will Appear Here';

  @override
  String get addedToFavorites => 'Added To Favorites';

  @override
  String get removedFromFavorites => 'Removed From Favorites';

  @override
  String selectedCount(Object value) {
    return '$value selected';
  }

  @override
  String get editPhoneNumber => 'Edit Phone Number';

  @override
  String get send => 'Send';

  @override
  String get stores => 'Stores';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get termsAndConditions => 'Terms and conditions';

  @override
  String get search => 'Search';

  @override
  String get searchStoreByName => 'Store Name';

  @override
  String get noStores => 'No Stores';

  @override
  String get promotionsAndOffers => 'Promotions & Offers';

  @override
  String get toTime => 'to';

  @override
  String get customerName => 'Customer name';

  @override
  String get newCustomer => 'New customer';

  @override
  String get editCustomer => 'Edit customer';

  @override
  String get street => 'Street';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get country => 'Country';

  @override
  String get postalCode => 'Postal code';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get newAgentType => 'New agent type';

  @override
  String get agentTypeName => 'Agent type name';

  @override
  String get agentTypeDescription => ' Agent type description';

  @override
  String get newSite => 'New site';

  @override
  String get siteName => 'Site name';

  @override
  String get startTime => 'Start time';

  @override
  String get endttime => 'End time';

  @override
  String get newAgent => 'New agent';

  @override
  String get agentType => 'Agent type ';

  @override
  String get socialSecurity => 'Social security';

  @override
  String get value => 'Value';

  @override
  String get expiryDate => 'Expiry date';

  @override
  String get language => 'Language';

  @override
  String get newContract => 'New contract';

  @override
  String get hoursPerMonth => 'Hours per month';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get selectAgentTypes => 'Select agent types';

  @override
  String get selectAgentType => 'Select agent type';

  @override
  String get addContacts => 'Add contacts';

  @override
  String get contactName => 'Contact name';

  @override
  String get contactValue => 'Contact value';

  @override
  String get contactNameEx => 'Website, email...';

  @override
  String get newContact => 'New contact';

  @override
  String get newHoliday => 'New holiday';

  @override
  String get newPlanification => 'New planification';

  @override
  String get planificationStatus => 'Planification Status';

  @override
  String get selectThePlanificationStatus => 'Select The Planification Status';

  @override
  String get invalidDateRange => 'Invalid Date Range!';

  @override
  String get selectSite => 'Select Site';

  @override
  String get addAgentType => 'Add agent type';

  @override
  String get notes => 'Notes';

  @override
  String get selectAgent => 'Select Agent';

  @override
  String get createdsuccssfully => 'Created successfully';

  @override
  String get genderMale => 'Man';

  @override
  String get genderFemale => 'Woman';

  @override
  String get gender => 'Gender';

  @override
  String get employmentType => 'Employment Type';

  @override
  String get contractor => 'Contractor';

  @override
  String get employee => 'Employee';

  @override
  String get agentStatus => 'Agent Status';

  @override
  String get active => 'Active';

  @override
  String get selectCustomer => 'Select Customer';

  @override
  String get agentStatusActive => 'Active';

  @override
  String get agentStatusSuspended => 'Suspended';

  @override
  String get agentEmploymentTypeContractor => 'Contractor';

  @override
  String get agentEmploymentTypeEmployee => 'Employee';

  @override
  String get addAgentPlanificationRelation => 'Add agents';

  @override
  String get agent => 'Agent';

  @override
  String get planificationStatusNew => 'New';

  @override
  String get planificationStatusDone => 'Done';

  @override
  String get planificationStatusCanceled => 'Canceled';

  @override
  String get changeRole => 'Change role';

  @override
  String get delete => 'Delete';

  @override
  String get customerList => 'Customers';

  @override
  String get customerDetails => 'Details';

  @override
  String get siteList => 'Site list';

  @override
  String get agentList => 'Agents';

  @override
  String get customer => 'Customer';

  @override
  String get name => 'Name';

  @override
  String get agentDetails => 'Agent details';

  @override
  String get siteDetails => 'Site details';

  @override
  String get contractDetails => 'Contract details';

  @override
  String get noContract => 'No contract';

  @override
  String get planificationList => 'Planification list';

  @override
  String get planificationDetails => 'Planification details';

  @override
  String get addPlanification => 'Add planification';

  @override
  String get selectACustomerFirst => 'Please select a customer first';

  @override
  String get site => 'Site';

  @override
  String get agentName => 'Agent name';

  @override
  String get start => 'Start';

  @override
  String get agents => 'Agents';

  @override
  String get customers => 'Customers';

  @override
  String get agentTypeList => 'Agent-type list';

  @override
  String get agentTypes => 'Agent Types';

  @override
  String get addAgent => 'Add agent';

  @override
  String get addCustomer => 'Add customer';

  @override
  String get previous => 'Previous';

  @override
  String get submit => 'Submit';

  @override
  String get agentInformations => 'Agent informations';

  @override
  String get accountDetails => 'Account details';

  @override
  String get employementDetails => 'Employement details';

  @override
  String get selectAgentTypesFirst => 'Select at least one agent type first';

  @override
  String get addAContact => 'Add a contact first';

  @override
  String get siteInformations => 'Site informations';

  @override
  String get contacts => 'Contacts';

  @override
  String get addSite => 'Add site';

  @override
  String get customerSites => 'Customer\'s sites';

  @override
  String get noSite => 'No site';

  @override
  String get holidaysHistory => 'Holidays history';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get noHolidays => 'No holidays';

  @override
  String get editAgentType => 'Edit agent type';

  @override
  String get editAgent => 'Edit agent';

  @override
  String get done => 'Done';

  @override
  String get editSite => 'Edit site';

  @override
  String get editContract => 'Edit contract';

  @override
  String get editHolidays => 'Edit holidays';

  @override
  String get pleaseConfirm => ' Please confirm';

  @override
  String get confirmDelete => 'Are you sure you want to delete this item?';

  @override
  String get createAnIntervention => 'Create an Intervention';

  @override
  String get isProCardRequired => 'ProCard Required';

  @override
  String get editPlanification => 'Edit planification';

  @override
  String get selectAnAgent => 'Please, Select an agent first!';

  @override
  String get agentNoGeoPoint => 'The agent has no geopoint';

  @override
  String get sentAt => 'Sent at';

  @override
  String get noCustomer => 'No customers';

  @override
  String get receivedAt => 'Received at';

  @override
  String get selectMonth => 'Select a month';

  @override
  String get lastKnownPosition => 'Last known position';

  @override
  String get proCardNeeded => 'ProCard needed';

  @override
  String get noAgent => 'No agents';

  @override
  String get noAgentType => 'No agent types';

  @override
  String get workedHours => 'Worked hours';

  @override
  String get percentage => 'Percentage';

  @override
  String get reload => 'Reload';

  @override
  String get workHours => 'Work Hours';

  @override
  String get siteWorkHours => 'Site\'s Work hours';

  @override
  String get cannotEditPlanification => 'You cannot edit this planification';

  @override
  String get archive => 'Archive';

  @override
  String get confirmCancelPlanification => 'Are you sure you want to cancel this planification?';

  @override
  String get confirmArchivePlanification => 'Are you sure you want to archive this planification?';

  @override
  String get planificationCanceled => 'Planification canceled successfully';

  @override
  String get planificationArchieved => 'Planification archived successfully';

  @override
  String get resetPassword => 'Reset password';

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
