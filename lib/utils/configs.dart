import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

const APP_NAME = 'Service Buddy Provider';
const DEFAULT_LANGUAGE = 'en';

const primaryColor = Color(0xFF25D366);

const DOMAIN_URL = 'https://servicebuddy.co.in'; // Don't add slash at the end of the url
const BASE_URL = "$DOMAIN_URL/api/";

/// You can specify in Admin Panel, These will be used if you don't specify in Admin Panel
const IOS_LINK_FOR_PARTNER = "https://apps.apple.com/in/app/handyman-provider-app/id1596025324";

const TERMS_CONDITION_URL = 'https://servicessbudy.apponrent.com/#/term-conditions';
const PRIVACY_POLICY_URL = 'https://servicessbudy.apponrent.com/#/privacy-policy';
const INQUIRY_SUPPORT_EMAIL = 'servicebuddy@gmail.com';

const GOOGLE_MAPS_API_KEY = 'AIzPOIUJwjZj458KL18-3mJM8tCqDYoV3NgrtQ';

const STRIPE_MERCHANT_COUNTRY_CODE = 'IN';

DateTime todayDate = DateTime(2022, 8, 24);

/// SADAD PAYMENT DETAIL
const SADAD_API_URL = 'https://api-s.sadad.qa';
const SADAD_PAY_URL = "https://d.sadad.qa";

/// You can update OneSignal Keys from Admin Panel in Setting.
/// These keys will be used if you haven't added in Admin Panel.
const ONESIGNAL_APP_ID = 'c30WERTY-c703-4bde-8689-9a33411ew7c7';
const ONESIGNAL_REST_KEY = "M2UwZWNjN2ItNzkyZi0DGRT3LWFlMzMtMThkYzU4New4NWZi";
const ONESIGNAL_CHANNEL_ID = "392cb0a8-5ce3-41a9-9895-35a63db57503";

Country defaultCountry() {
  return Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 91,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
    fullExampleWithPlusSign: '+919123456789',
  );
}
