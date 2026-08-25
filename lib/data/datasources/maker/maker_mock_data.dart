const mockMakerProductsData = [
  {
    "id": "prod-fin-001",
    "name": "Commercial SME Loan Facility",
    "description": "Short-to-medium term business capital underwriting & disbursement workflows.",
    "category": "Corporate Finance",
    "status": "active",
    "formCount": 2,
    "iconName": "account_balance"
  },
  {
    "id": "prod-ins-002",
    "name": "Commercial Property Risk Cover",
    "description": "Enterprise asset loss, fire & comprehensive business liability insurance.",
    "category": "Underwriting",
    "status": "active",
    "formCount": 2,
    "iconName": "shield"
  },
  {
    "id": "prod-ops-003",
    "name": "Vendor Merchant KYC Onboarding",
    "description": "Legal entity registration, beneficial owner verifications & compliance checks.",
    "category": "Compliance",
    "status": "active",
    "formCount": 1,
    "iconName": "verified_user"
  }
];

const mockMakerFormsData = {
  "prod-fin-001": [
    {
      "id": "form-sme-primary",
      "productId": "prod-fin-001",
      "title": "Business Entity & Loan Profiling",
      "description": "Capture legal trading structure, turnover metrics and requested principal limits.",
      "fieldCount": 8
    },
    {
      "id": "form-sme-collateral",
      "productId": "prod-fin-001",
      "title": "Collateral & Guarantee Schedule",
      "description": "Collateral asset registry, personal director guarantees and audit declarations.",
      "fieldCount": 5
    }
  ],
  "prod-ins-002": [
    {
      "id": "form-ins-asset",
      "productId": "prod-ins-002",
      "title": "Physical Property Valuation",
      "description": "Structure location, built square footage, fire suppression and security protocols.",
      "fieldCount": 7
    },
    {
      "id": "form-ins-liability",
      "productId": "prod-ins-002",
      "title": "Third-Party Liability Cover",
      "description": "Public indemnity limits, claims history and operational exposure.",
      "fieldCount": 4
    }
  ],
  "prod-ops-003": [
    {
      "id": "form-kyc-entity",
      "productId": "prod-ops-003",
      "title": "Beneficial Ownership Registry",
      "description": "Direct shareholder split, NTN/Tax identity and anti-money laundering records.",
      "fieldCount": 6
    }
  ]
};

const mockDynamicFieldsData = {
  "form-sme-primary": [
    {
      "id": "f-1",
      "key": "companyName",
      "label": "Registered Legal Entity Name",
      "type": "text",
      "required": true,
      "placeholder": "e.g. Apex Industrial Solutions (Pvt) Ltd."
    },
    {
      "id": "f-2",
      "key": "contactEmail",
      "label": "Official Accounts Email",
      "type": "email",
      "required": true,
      "placeholder": "accounts@company.com"
    },
    {
      "id": "f-3",
      "key": "requestedAmount",
      "label": "Requested Facility Limit (PKR)",
      "type": "number",
      "required": true,
      "placeholder": "5000000"
    },
    {
      "id": "f-4",
      "key": "incorporationDate",
      "label": "Date of Incorporation",
      "type": "date",
      "required": true
    },
    {
      "id": "f-5",
      "key": "facilityStructure",
      "label": "Credit Facility Type",
      "type": "dropdown",
      "required": true,
      "options": ["Running Finance (Revolving)", "Term Loan", "Letter of Credit (LC)", "Bank Guarantee"]
    },
    {
      "id": "f-6",
      "key": "isTaxFiler",
      "label": "Active Active Taxpayer Status (ATL Filer)",
      "type": "radio",
      "required": true,
      "options": ["Verified Active", "Non-Filer", "Exempt Entity"]
    },
    {
      "id": "f-7",
      "key": "requiresMoratorium",
      "label": "Request 6-Month Principal Grace Period",
      "type": "checkbox",
      "required": false
    },
    {
      "id": "f-8",
      "key": "businessJustification",
      "label": "Operational Loan Purpose Summary",
      "type": "multiline",
      "required": true,
      "placeholder": "Describe working capital allocation, machinery procurement or cashflow expansion goals..."
    }
  ],
  "form-sme-collateral": [
    {
      "id": "f-c1",
      "key": "collateralType",
      "label": "Primary Security Class",
      "type": "dropdown",
      "required": true,
      "options": ["Commercial Real Estate Mortgage", "Hypothecation of Plant & Stocks", "Cash Margin / TDR"]
    },
    {
      "id": "f-c2",
      "key": "collateralValue",
      "label": "Estimated Fair Market Value (PKR)",
      "type": "number",
      "required": true,
      "placeholder": "7500000"
    },
    {
      "id": "f-c3",
      "key": "guarantorPhone",
      "label": "Primary Guarantor Phone Number",
      "type": "phone",
      "required": true,
      "placeholder": "03001234567"
    },
    {
      "id": "f-c4",
      "key": "thirdPartyEncumbrance",
      "label": "Existing Charges with Other Banks",
      "type": "radio",
      "required": true,
      "options": ["Pari-Passu Charge", "First Exclusive Charge", "Second Subordinate Charge", "Clean / No Prior Liens"]
    },
    {
      "id": "f-c5",
      "key": "undertakingAffidavit",
      "label": "Directors provide personal unencumbered surety",
      "type": "checkbox",
      "required": true
    }
  ]
};