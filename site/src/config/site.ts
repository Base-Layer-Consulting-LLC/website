export const siteConfig = {
    url: import.meta.env.PUBLIC_SITE_ADDR ?? "https://example.com",
    name: import.meta.env.PUBLIC_BUSINESS_NAME ?? "Base Layer Consulting LLC",
    nameShort: import.meta.env.PUBLIC_BUSINESS_NAME_SHORT ?? "Base Layer LLC",
    tagline: import.meta.env.PUBLIC_BUSINESS_TAGLINE ?? "Core infrastructure & platform consulting for your business.",
    emailMain: import.meta.env.PUBLIC_CONTACT_EMAIL_ADDR_MAIN ?? "jack@base-layer.llc",
    phoneMain: import.meta.env.CONTACT_PHONE_NUMBER_MAIN ?? "000-000-0000",
    formspreeContactFormId: import.meta.env.PUBLIC_FORMSPREE_CONTACT_FORM_ID ?? ""
}