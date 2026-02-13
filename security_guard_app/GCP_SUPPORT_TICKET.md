# GCP Support Ticket - Firebase API Blocked by Organization Policy

## Issue Summary
Unable to enable Firebase on GCP project due to organization policy restrictions blocking Firebase APIs.

---

## Details to Include in Support Ticket

**Google Account**: saqibmaklai@gmail.com

**GCP Project ID**: security-guard-1770233111  
**GCP Project Number**: 706611404308

**Organization**: [Your organization name - check GCP Console → Settings]

**Error Message**:
```
Error: Failed to add Firebase to Google Cloud Platform project.
HTTP Error: 403, The caller does not have permission.
Status: PERMISSION_DENIED
```

**Error Details**:
- Command: `firebase projects:addfirebase security-guard-1770233111`
- API Endpoint: `POST https://firebase.googleapis.com/v1beta1/projects/security-guard-1770233111:addFirebase`
- Response Code: 403
- Response Body: `{"error":{"code":403,"message":"The caller does not have permission","status":"PERMISSION_DENIED"}}`

**Symptoms**:
1. User has **Owner** role on GCP project and Firebase roles
2. Successfully created GCP project `security-guard-1770233111`
3. Cannot add Firebase resources due to org policy blocking Firebase APIs
4. Error suggests: "You need to select a resource under an organisation to manage policies"

**What's Blocked**:
- Firebase API (`firebase.googleapis.com`)
- Cloud Functions
- Cloud Firestore
- Firebase Authentication

---

## How to Contact GCP Support

### **Option 1: GCP Console (Recommended)**
1. Go to https://console.cloud.google.com/
2. Top-right → **Help** → **Create a support ticket**
3. Select **Cloud Support Plan** (or free tier if available)
4. **Issue Type**: API / Services
5. **Component**: Firebase / Cloud Functions
6. **Severity**: High (blocks app development)
7. **Description**: Copy the details above
8. Click **Create**

### **Option 2: Firebase Console**
1. Go to https://console.firebase.google.com/
2. Click your profile → **Support**
3. Create a new issue

### **Option 3: Email Support**
Firebase Support: support@firebase.google.com  
GCP Support: https://cloud.google.com/support/

---

## What to Ask GCP Support

**Question for support**:
> "Our organization has a policy blocking Firebase APIs. We need to either:
> 
> A) Disable the organization policy constraint that blocks Firebase for this specific project, OR
> B) Create a separate standalone GCP project outside the organization that allows Firebase
> 
> What is the recommended approach and how do we proceed?"

---

## Meanwhile: Use the App with Mock Service

The Security Guard App is **100% functional locally** using the built-in `MockService`. You can test all features without Firebase:

```bash
cd "d:\Development Work Feb032026\Security Guard App\security_guard_app"
flutter pub get
flutter run -d windows
```

**What works with mock service**:
✅ Login screen  
✅ User creation  
✅ User management (block/unblock)  
✅ Email invitations (opens mail client)  
✅ QR code generation  
✅ Reports dashboard  
✅ All UI screens & navigation  

**What requires Firebase (after support fixes policy)**:
- Persistent Cloud Firestore storage
- Firebase Authentication backend
- Cloud Function for email password-reset links

---

## After GCP Support Responds

Once they resolve the organization policy issue, run:

```powershell
firebase projects:addfirebase security-guard-1770233111
firebase functions:config:set invite.secret="YOUR_STRONG_SECRET"
firebase deploy --only functions:api --project security-guard-1770233111
```

Then test the Cloud Function:
```bash
curl -X POST 'https://<region>-security-guard-1770233111.cloudfunctions.net/api/invite' \
  -H 'Content-Type: application/json' \
  -H 'x-invite-secret: YOUR_STRONG_SECRET' \
  -d '{"name":"Test User","email":"test@example.com","daysActive":30}'
```

---

## Support Timeline

- **GCP Free Support**: 24-48 hours response
- **Paid Support**: Priority response (check your plan)
- **In the meantime**: Test the app locally with MockService

---

**Created**: February 4, 2026  
**Status**: Awaiting GCP Support Response
