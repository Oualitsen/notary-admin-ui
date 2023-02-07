import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'NOTARY'**
  String get appName;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogout;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get userName;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required field'**
  String get requiredField;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'ok'**
  String get ok;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @iDontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have an account'**
  String get iDontHaveAnAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get repeatPassword;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @passwordDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordDontMatch;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @inputEmail.
  ///
  /// In en, this message translates to:
  /// **'Input Email'**
  String get inputEmail;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @editEmail.
  ///
  /// In en, this message translates to:
  /// **'Edit email'**
  String get editEmail;

  /// No description provided for @editInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit info'**
  String get editInfo;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @tapToVerifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Tap to validate your email'**
  String get tapToVerifyYourEmail;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @retypePassword.
  ///
  /// In en, this message translates to:
  /// **'Retype password'**
  String get retypePassword;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChanged;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPassword;

  /// No description provided for @recoverPassword.
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get recoverPassword;

  /// No description provided for @inputUsername.
  ///
  /// In en, this message translates to:
  /// **'Input username'**
  String get inputUsername;

  /// No description provided for @usernameNotFound.
  ///
  /// In en, this message translates to:
  /// **'Username not found'**
  String get usernameNotFound;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @promotions.
  ///
  /// In en, this message translates to:
  /// **'Promotions'**
  String get promotions;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @promotionEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends on:'**
  String get promotionEnds;

  /// No description provided for @promotionStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get promotionStarted;

  /// No description provided for @deliveryAvailable.
  ///
  /// In en, this message translates to:
  /// **'Delivery available'**
  String get deliveryAvailable;

  /// No description provided for @noMedia.
  ///
  /// In en, this message translates to:
  /// **'No media'**
  String get noMedia;

  /// No description provided for @couldNotLoadVideo.
  ///
  /// In en, this message translates to:
  /// **'Sorry could not load video'**
  String get couldNotLoadVideo;

  /// No description provided for @couldNotLoadData.
  ///
  /// In en, this message translates to:
  /// **'Could not load data'**
  String get couldNotLoadData;

  /// No description provided for @usePhoneInstead.
  ///
  /// In en, this message translates to:
  /// **'Use phone number instead'**
  String get usePhoneInstead;

  /// No description provided for @useEmailInstead.
  ///
  /// In en, this message translates to:
  /// **'Use email instead'**
  String get useEmailInstead;

  /// No description provided for @phoneVerificationFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification error'**
  String get phoneVerificationFailedTitle;

  /// No description provided for @phoneVerificationFailedText.
  ///
  /// In en, this message translates to:
  /// **'Sorry we were unable to verify your phone number'**
  String get phoneVerificationFailedText;

  /// No description provided for @invalidCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidCodeTitle;

  /// No description provided for @invalidCodeText.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidCodeText;

  /// No description provided for @invalidValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid value'**
  String get invalidValue;

  /// No description provided for @phoneNumberUpdated.
  ///
  /// In en, this message translates to:
  /// **'Phone number updated successfully'**
  String get phoneNumberUpdated;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid Email'**
  String get invalidEmail;

  /// No description provided for @emailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Email Updated successfully'**
  String get emailUpdated;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'404 Not Found'**
  String get notFound;

  /// No description provided for @da.
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get da;

  /// No description provided for @maxValue.
  ///
  /// In en, this message translates to:
  /// **'Value must be lower than or equal {value}'**
  String maxValue(Object value);

  /// No description provided for @minValue.
  ///
  /// In en, this message translates to:
  /// **'Value must be greater than or equal {value}'**
  String minValue(Object value);

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @range.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get range;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'FavoriS'**
  String get favoritesTitle;

  /// No description provided for @favoritesWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Favorites Will Appear Here'**
  String get favoritesWillAppearHere;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added To Favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed From Favorites'**
  String get removedFromFavorites;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{value} selected'**
  String selectedCount(Object value);

  /// No description provided for @editPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Edit Phone Number'**
  String get editPhoneNumber;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @stores.
  ///
  /// In en, this message translates to:
  /// **'Stores'**
  String get stores;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get termsAndConditions;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchStoreByName.
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get searchStoreByName;

  /// No description provided for @noStores.
  ///
  /// In en, this message translates to:
  /// **'No Stores'**
  String get noStores;

  /// No description provided for @promotionsAndOffers.
  ///
  /// In en, this message translates to:
  /// **'Promotions & Offers'**
  String get promotionsAndOffers;

  /// No description provided for @toTime.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get toTime;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get customerName;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New customer'**
  String get newCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit customer'**
  String get editCustomer;

  /// No description provided for @street.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get street;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @postalCode.
  ///
  /// In en, this message translates to:
  /// **'Postal code'**
  String get postalCode;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @newAgentType.
  ///
  /// In en, this message translates to:
  /// **'New agent type'**
  String get newAgentType;

  /// No description provided for @agentTypeName.
  ///
  /// In en, this message translates to:
  /// **'Agent type name'**
  String get agentTypeName;

  /// No description provided for @agentTypeDescription.
  ///
  /// In en, this message translates to:
  /// **' Agent type description'**
  String get agentTypeDescription;

  /// No description provided for @newSite.
  ///
  /// In en, this message translates to:
  /// **'New site'**
  String get newSite;

  /// No description provided for @siteName.
  ///
  /// In en, this message translates to:
  /// **'Site name'**
  String get siteName;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @endttime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endttime;

  /// No description provided for @newAgent.
  ///
  /// In en, this message translates to:
  /// **'New agent'**
  String get newAgent;

  /// No description provided for @agentType.
  ///
  /// In en, this message translates to:
  /// **'Agent type '**
  String get agentType;

  /// No description provided for @socialSecurity.
  ///
  /// In en, this message translates to:
  /// **'Social security'**
  String get socialSecurity;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiryDate;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @newContract.
  ///
  /// In en, this message translates to:
  /// **'New contract'**
  String get newContract;

  /// No description provided for @hoursPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Hours per month'**
  String get hoursPerMonth;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @selectAgentTypes.
  ///
  /// In en, this message translates to:
  /// **'Select agent types'**
  String get selectAgentTypes;

  /// No description provided for @selectAgentType.
  ///
  /// In en, this message translates to:
  /// **'Select agent type'**
  String get selectAgentType;

  /// No description provided for @addContacts.
  ///
  /// In en, this message translates to:
  /// **'Add contacts'**
  String get addContacts;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact name'**
  String get contactName;

  /// No description provided for @contactValue.
  ///
  /// In en, this message translates to:
  /// **'Contact value'**
  String get contactValue;

  /// No description provided for @contactNameEx.
  ///
  /// In en, this message translates to:
  /// **'Website, email...'**
  String get contactNameEx;

  /// No description provided for @newContact.
  ///
  /// In en, this message translates to:
  /// **'New contact'**
  String get newContact;

  /// No description provided for @newHoliday.
  ///
  /// In en, this message translates to:
  /// **'New holiday'**
  String get newHoliday;

  /// No description provided for @newPlanification.
  ///
  /// In en, this message translates to:
  /// **'New planification'**
  String get newPlanification;

  /// No description provided for @planificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Planification Status'**
  String get planificationStatus;

  /// No description provided for @selectThePlanificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Select The Planification Status'**
  String get selectThePlanificationStatus;

  /// No description provided for @invalidDateRange.
  ///
  /// In en, this message translates to:
  /// **'Invalid Date Range!'**
  String get invalidDateRange;

  /// No description provided for @selectSite.
  ///
  /// In en, this message translates to:
  /// **'Select Site'**
  String get selectSite;

  /// No description provided for @addAgentType.
  ///
  /// In en, this message translates to:
  /// **'Add agent type'**
  String get addAgentType;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @selectAgent.
  ///
  /// In en, this message translates to:
  /// **'Select Agent'**
  String get selectAgent;

  /// No description provided for @createdsuccssfully.
  ///
  /// In en, this message translates to:
  /// **'Created successfully'**
  String get createdsuccssfully;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Man'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Woman'**
  String get genderFemale;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @employmentType.
  ///
  /// In en, this message translates to:
  /// **'Employment Type'**
  String get employmentType;

  /// No description provided for @contractor.
  ///
  /// In en, this message translates to:
  /// **'Contractor'**
  String get contractor;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @agentStatus.
  ///
  /// In en, this message translates to:
  /// **'Agent Status'**
  String get agentStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// No description provided for @agentStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get agentStatusActive;

  /// No description provided for @agentStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get agentStatusSuspended;

  /// No description provided for @agentEmploymentTypeContractor.
  ///
  /// In en, this message translates to:
  /// **'Contractor'**
  String get agentEmploymentTypeContractor;

  /// No description provided for @agentEmploymentTypeEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get agentEmploymentTypeEmployee;

  /// No description provided for @addAgentPlanificationRelation.
  ///
  /// In en, this message translates to:
  /// **'Add agents'**
  String get addAgentPlanificationRelation;

  /// No description provided for @agent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get agent;

  /// No description provided for @planificationStatusNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get planificationStatusNew;

  /// No description provided for @planificationStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get planificationStatusDone;

  /// No description provided for @planificationStatusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Canceled'**
  String get planificationStatusCanceled;

  /// No description provided for @changeRole.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get changeRole;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @customerList.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customerList;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get customerDetails;

  /// No description provided for @siteList.
  ///
  /// In en, this message translates to:
  /// **'Site list'**
  String get siteList;

  /// No description provided for @agentList.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get agentList;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @agentDetails.
  ///
  /// In en, this message translates to:
  /// **'Agent details'**
  String get agentDetails;

  /// No description provided for @siteDetails.
  ///
  /// In en, this message translates to:
  /// **'Site details'**
  String get siteDetails;

  /// No description provided for @contractDetails.
  ///
  /// In en, this message translates to:
  /// **'Contract details'**
  String get contractDetails;

  /// No description provided for @noContract.
  ///
  /// In en, this message translates to:
  /// **'No contract'**
  String get noContract;

  /// No description provided for @planificationList.
  ///
  /// In en, this message translates to:
  /// **'Planification list'**
  String get planificationList;

  /// No description provided for @planificationDetails.
  ///
  /// In en, this message translates to:
  /// **'Planification details'**
  String get planificationDetails;

  /// No description provided for @addPlanification.
  ///
  /// In en, this message translates to:
  /// **'Add planification'**
  String get addPlanification;

  /// No description provided for @selectACustomerFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer first'**
  String get selectACustomerFirst;

  /// No description provided for @site.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get site;

  /// No description provided for @agentName.
  ///
  /// In en, this message translates to:
  /// **'Agent name'**
  String get agentName;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @agents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get agents;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @agentTypeList.
  ///
  /// In en, this message translates to:
  /// **'Agent-type list'**
  String get agentTypeList;

  /// No description provided for @agentTypes.
  ///
  /// In en, this message translates to:
  /// **'Agent Types'**
  String get agentTypes;

  /// No description provided for @addAgent.
  ///
  /// In en, this message translates to:
  /// **'Add agent'**
  String get addAgent;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add customer'**
  String get addCustomer;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @agentInformations.
  ///
  /// In en, this message translates to:
  /// **'Agent informations'**
  String get agentInformations;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get accountDetails;

  /// No description provided for @employementDetails.
  ///
  /// In en, this message translates to:
  /// **'Employement details'**
  String get employementDetails;

  /// No description provided for @selectAgentTypesFirst.
  ///
  /// In en, this message translates to:
  /// **'Select at least one agent type first'**
  String get selectAgentTypesFirst;

  /// No description provided for @addAContact.
  ///
  /// In en, this message translates to:
  /// **'Add a contact first'**
  String get addAContact;

  /// No description provided for @siteInformations.
  ///
  /// In en, this message translates to:
  /// **'Site informations'**
  String get siteInformations;

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @addSite.
  ///
  /// In en, this message translates to:
  /// **'Add site'**
  String get addSite;

  /// No description provided for @customerSites.
  ///
  /// In en, this message translates to:
  /// **'Customer\'s sites'**
  String get customerSites;

  /// No description provided for @noSite.
  ///
  /// In en, this message translates to:
  /// **'No site'**
  String get noSite;

  /// No description provided for @holidaysHistory.
  ///
  /// In en, this message translates to:
  /// **'Holidays history'**
  String get holidaysHistory;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccessfully;

  /// No description provided for @noHolidays.
  ///
  /// In en, this message translates to:
  /// **'No holidays'**
  String get noHolidays;

  /// No description provided for @editAgentType.
  ///
  /// In en, this message translates to:
  /// **'Edit agent type'**
  String get editAgentType;

  /// No description provided for @editAgent.
  ///
  /// In en, this message translates to:
  /// **'Edit agent'**
  String get editAgent;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @editSite.
  ///
  /// In en, this message translates to:
  /// **'Edit site'**
  String get editSite;

  /// No description provided for @editContract.
  ///
  /// In en, this message translates to:
  /// **'Edit contract'**
  String get editContract;

  /// No description provided for @editHolidays.
  ///
  /// In en, this message translates to:
  /// **'Edit holidays'**
  String get editHolidays;

  /// No description provided for @pleaseConfirm.
  ///
  /// In en, this message translates to:
  /// **' Please confirm'**
  String get pleaseConfirm;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDelete;

  /// No description provided for @createAnIntervention.
  ///
  /// In en, this message translates to:
  /// **'Create an Intervention'**
  String get createAnIntervention;

  /// No description provided for @isProCardRequired.
  ///
  /// In en, this message translates to:
  /// **'ProCard Required'**
  String get isProCardRequired;

  /// No description provided for @editPlanification.
  ///
  /// In en, this message translates to:
  /// **'Edit planification'**
  String get editPlanification;

  /// No description provided for @selectAnAgent.
  ///
  /// In en, this message translates to:
  /// **'Please, Select an agent first!'**
  String get selectAnAgent;

  /// No description provided for @agentNoGeoPoint.
  ///
  /// In en, this message translates to:
  /// **'The agent has no geopoint'**
  String get agentNoGeoPoint;

  /// No description provided for @sentAt.
  ///
  /// In en, this message translates to:
  /// **'Sent at'**
  String get sentAt;

  /// No description provided for @noCustomer.
  ///
  /// In en, this message translates to:
  /// **'No customers'**
  String get noCustomer;

  /// No description provided for @receivedAt.
  ///
  /// In en, this message translates to:
  /// **'Received at'**
  String get receivedAt;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select a month'**
  String get selectMonth;

  /// No description provided for @lastKnownPosition.
  ///
  /// In en, this message translates to:
  /// **'Last known position'**
  String get lastKnownPosition;

  /// No description provided for @proCardNeeded.
  ///
  /// In en, this message translates to:
  /// **'ProCard needed'**
  String get proCardNeeded;

  /// No description provided for @noAgent.
  ///
  /// In en, this message translates to:
  /// **'No agents'**
  String get noAgent;

  /// No description provided for @noAgentType.
  ///
  /// In en, this message translates to:
  /// **'No agent types'**
  String get noAgentType;

  /// No description provided for @workedHours.
  ///
  /// In en, this message translates to:
  /// **'Worked hours'**
  String get workedHours;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @workHours.
  ///
  /// In en, this message translates to:
  /// **'Work Hours'**
  String get workHours;

  /// No description provided for @siteWorkHours.
  ///
  /// In en, this message translates to:
  /// **'Site\'s Work hours'**
  String get siteWorkHours;

  /// No description provided for @cannotEditPlanification.
  ///
  /// In en, this message translates to:
  /// **'You cannot edit this planification'**
  String get cannotEditPlanification;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @confirmCancelPlanification.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this planification?'**
  String get confirmCancelPlanification;

  /// No description provided for @confirmArchivePlanification.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to archive this planification?'**
  String get confirmArchivePlanification;

  /// No description provided for @planificationCanceled.
  ///
  /// In en, this message translates to:
  /// **'Planification canceled successfully'**
  String get planificationCanceled;

  /// No description provided for @planificationArchieved.
  ///
  /// In en, this message translates to:
  /// **'Planification archived successfully'**
  String get planificationArchieved;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date Of Birth'**
  String get dateOfBirth;

  /// No description provided for @cardId.
  ///
  /// In en, this message translates to:
  /// **'Id Card'**
  String get cardId;

  /// No description provided for @frontImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Front image url'**
  String get frontImageUrl;

  /// No description provided for @backImageUrl.
  ///
  /// In en, this message translates to:
  /// **'Back image url'**
  String get backImageUrl;

  /// No description provided for @idCardInfo.
  ///
  /// In en, this message translates to:
  /// **'Id card info'**
  String get idCardInfo;

  /// No description provided for @updatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get updatedSuccessfully;

  /// No description provided for @addFileTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a file'**
  String get addFileTitle;

  /// No description provided for @editFileName.
  ///
  /// In en, this message translates to:
  /// **'Edit file name'**
  String get editFileName;

  /// No description provided for @newAssistant.
  ///
  /// In en, this message translates to:
  /// **'New assistant'**
  String get newAssistant;

  /// No description provided for @credentails.
  ///
  /// In en, this message translates to:
  /// **'Credentails'**
  String get credentails;

  /// No description provided for @assistantList.
  ///
  /// In en, this message translates to:
  /// **'Assistants'**
  String get assistantList;

  /// No description provided for @idCard.
  ///
  /// In en, this message translates to:
  /// **'Id Card'**
  String get idCard;

  /// No description provided for @fileList.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get fileList;

  /// No description provided for @notaryService.
  ///
  /// In en, this message translates to:
  /// **'Notary Service'**
  String get notaryService;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
