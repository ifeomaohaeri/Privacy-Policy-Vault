;; ADVANCED DATA GOVERNANCE & CONSENT MANAGEMENT SYSTEM

;; A comprehensive blockchain-based solution for managing user privacy,
;; data processing consent, GDPR compliance, and digital rights management.
;; Provides immutable audit trails, automated consent verification,
;; and regulatory compliance tools for modern data protection requirements.

;; SECURITY & ACCESS CONTROL CONSTANTS

(define-constant SYSTEM_ADMINISTRATOR tx-sender)
(define-constant UNAUTHORIZED_ACCESS_ERROR (err u100))
(define-constant PRIVACY_POLICY_NOT_FOUND_ERROR (err u101))
(define-constant INVALID_POLICY_VERSION_ERROR (err u102))
(define-constant CONSENT_ALREADY_RECORDED_ERROR (err u103))
(define-constant USER_CONSENT_NOT_FOUND_ERROR (err u104))
(define-constant DUPLICATE_POLICY_VERSION_ERROR (err u105))
(define-constant INVALID_DATA_CLASSIFICATION_ERROR (err u106))
(define-constant INVALID_PROCESSING_PURPOSE_ERROR (err u107))
(define-constant INVALID_INPUT_DATA_ERROR (err u108))

;; SYSTEM STATE MANAGEMENT VARIABLES

(define-data-var latest-active-policy-version uint u0)
(define-data-var total-registered-policies uint u0)
(define-data-var emergency-system-lockdown bool false)

;; PRIVACY POLICY REGISTRY
;; Maps policy versions to their comprehensive metadata

(define-map comprehensive-privacy-policy-registry
  { policy-version-identifier: uint }
  {
    policy-document-title: (string-ascii 100),
    cryptographic-content-hash: (buff 32),
    legal-effective-timestamp: uint,
    policy-expiration-timestamp: (optional uint),
    policy-author-principal: principal,
    policy-activation-status: bool
  }
)

;; USER CONSENT MANAGEMENT SYSTEM
;; Tracks individual user consent across different policy versions

(define-map user-consent-tracking-registry
  { consenting-user-principal: principal, applicable-policy-version: uint }
  {
    consent-recorded-timestamp: uint,
    legal-consent-classification: (string-ascii 20),
    authorized-data-processing-activities: (list 10 (string-ascii 50)),
    maximum-data-retention-duration: uint,
    consent-revocation-permitted: bool
  }
)

;; PERSONAL DATA PROCESSING PREFERENCES
;; Individual user preferences for data handling and communication

(define-map individual-privacy-preferences-store
  { preference-owner-principal: principal }
  {
    marketing-communication-consent: bool,
    behavioral-analytics-consent: bool,
    external-data-sharing-consent: bool,
    preferred-data-retention-duration: uint,
    primary-communication-channel: (string-ascii 20),
    preferences-last-modified-timestamp: uint
  }
)

;; DATA PROCESSING ACTIVITY AUDIT LOG
;; Comprehensive logging of all data processing activities

(define-map data-processing-audit-trail
  { processing-activity-identifier: uint }
  {
    subject-user-principal: principal,
    processed-data-classification: (string-ascii 30),
    data-processing-legal-purpose: (string-ascii 50),
    processing-execution-timestamp: uint,
    legal-basis-for-processing: (string-ascii 50),
    data-retention-expiry-timestamp: uint
  }
)

;; DATA SUBJECT RIGHTS MANAGEMENT
;; Handles deletion requests and other data subject rights

(define-map data-subject-deletion-request-queue
  { requesting-user-principal: principal, deletion-request-identifier: uint }
  {
    deletion-request-submission-timestamp: uint,
    requested-data-categories-for-deletion: (list 10 (string-ascii 30)),
    deletion-request-processing-status: (string-ascii 20),
    deletion-completion-timestamp: (optional uint),
    deletion-status-explanation: (optional (string-ascii 200))
  }
)

;; SYSTEM COUNTERS AND IDENTIFIERS

(define-data-var next-available-processing-record-id uint u1)
(define-data-var next-available-deletion-request-id uint u1)

;; INPUT VALIDATION HELPER FUNCTIONS

;; Validate policy document title
(define-private (validate-policy-title (title (string-ascii 100)))
  (let ((title-length (len title)))
    (and (> title-length u0) (<= title-length u100))
  )
)

;; Validate content hash
(define-private (validate-content-hash (hash (buff 32)))
  (is-eq (len hash) u32)
)

;; Validate timestamp values
(define-private (validate-timestamp (timestamp uint))
  (and (> timestamp u0) (<= timestamp u4294967295)) ;; Max uint32 value
)

;; Validate retention duration (max 10 years in blocks, assuming ~10 min blocks)
(define-private (validate-retention-duration (duration uint))
  (and (> duration u0) (<= duration u525600)) ;; ~10 years worth of blocks
)

;; Validate policy version identifier
(define-private (validate-policy-version (version uint))
  (and (> version u0) (<= version u1000000)) ;; Reasonable upper limit
)

;; Validate string content (non-empty and reasonable length)
(define-private (validate-string-content (content (string-ascii 50)))
  (let ((content-length (len content)))
    (and (> content-length u0) (<= content-length u50))
  )
)

;; Validate data classification categories
(define-private (validate-data-classification (classification (string-ascii 30)))
  (or
    (is-eq classification "personal")
    (is-eq classification "financial")
    (is-eq classification "health")
    (is-eq classification "behavioral")
    (is-eq classification "technical")
  )
)

;; Validate communication channel
(define-private (validate-communication-channel (channel (string-ascii 20)))
  (or 
    (is-eq channel "email")
    (is-eq channel "phone")
    (is-eq channel "mail")
    (is-eq channel "none")
  )
)

;; Validate consent classification
(define-private (validate-consent-classification (classification (string-ascii 20)))
  (or 
    (is-eq classification "explicit") 
    (is-eq classification "implicit")
    (is-eq classification "withdrawn")
  )
)

;; Validate processing status
(define-private (validate-processing-status (status (string-ascii 20)))
  (or
    (is-eq status "pending")
    (is-eq status "processing")
    (is-eq status "completed")
    (is-eq status "rejected")
  )
)

;; Validate processing activities list
(define-private (validate-processing-activities (activities (list 10 (string-ascii 50))))
  (and 
    (> (len activities) u0)
    (<= (len activities) u10)
  )
)

;; Validate data categories list
(define-private (validate-data-categories (categories (list 10 (string-ascii 30))))
  (and 
    (> (len categories) u0)
    (<= (len categories) u10)
  )
)

;; Validate deletion request identifier
(define-private (validate-deletion-request-id (request-id uint))
  (and (> request-id u0) (<= request-id u1000000)) ;; Reasonable upper limit
)

;; Validate optional timestamp
(define-private (validate-optional-timestamp (timestamp (optional uint)))
  (match timestamp
    ts (validate-timestamp ts)
    true
  )
)

;; Validate principal (basic validation to ensure it's not a null or invalid principal)
(define-private (validate-principal (user-principal principal))
  ;; Check that the principal is not equal to a known invalid pattern
  ;; In Clarity, we can't do extensive principal validation, but we can check basic patterns
  (not (is-eq user-principal 'SP000000000000000000002Q6VF78))
)

;; PUBLIC READ-ONLY INTERFACE FUNCTIONS

;; Retrieve the currently active policy version number
(define-read-only (fetch-current-active-policy-version)
  (var-get latest-active-policy-version)
)

;; Get comprehensive policy information by version identifier
(define-read-only (retrieve-policy-by-version (policy-version-number uint))
  (map-get? comprehensive-privacy-policy-registry { policy-version-identifier: policy-version-number })
)

;; Fetch user's consent record for a specific policy version
(define-read-only (get-user-consent-record-by-version (user-principal principal) (policy-version-number uint))
  (map-get? user-consent-tracking-registry { consenting-user-principal: user-principal, applicable-policy-version: policy-version-number })
)

;; Get user's consent status for the currently active policy
(define-read-only (retrieve-current-policy-consent-status (user-principal principal))
  (let ((active-policy-version (var-get latest-active-policy-version)))
    (map-get? user-consent-tracking-registry { consenting-user-principal: user-principal, applicable-policy-version: active-policy-version })
  )
)

;; Fetch user's personal data processing preferences
(define-read-only (get-user-privacy-preferences (user-principal principal))
  (map-get? individual-privacy-preferences-store { preference-owner-principal: user-principal })
)

;; Verify if user has valid consent for current active policy
(define-read-only (verify-user-has-valid-current-consent (user-principal principal))
  (let (
    (current-active-policy-version (var-get latest-active-policy-version))
    (user-consent-record (map-get? user-consent-tracking-registry { consenting-user-principal: user-principal, applicable-policy-version: current-active-policy-version }))
  )
    (match user-consent-record
      consent-record-data (and 
        (not (is-eq (get legal-consent-classification consent-record-data) "withdrawn"))
        (get consent-revocation-permitted consent-record-data)
      )
      false
    )
  )
)

;; Retrieve specific data processing activity record
(define-read-only (fetch-data-processing-audit-record (processing-record-identifier uint))
  (map-get? data-processing-audit-trail { processing-activity-identifier: processing-record-identifier })
)

;; Get deletion request details by user and request ID
(define-read-only (retrieve-deletion-request-details (user-principal principal) (deletion-request-identifier uint))
  (map-get? data-subject-deletion-request-queue { requesting-user-principal: user-principal, deletion-request-identifier: deletion-request-identifier })
)

;; Check system emergency lockdown status
(define-read-only (check-system_emergency_lockdown_status)
  (var-get emergency-system-lockdown)
)

;; ADMINISTRATIVE POLICY MANAGEMENT FUNCTIONS

;; Create and register a new privacy policy version
(define-public (register-new-privacy-policy 
  (policy-document-title (string-ascii 100))
  (cryptographic-content-hash (buff 32))
  (legal-effective-timestamp uint)
  (policy-expiration-timestamp (optional uint))
)
  (let (
    (new-policy-version-number (+ (var-get total-registered-policies) u1))
    (current-blockchain-height block-height)
  )
    (asserts! (is-eq tx-sender SYSTEM_ADMINISTRATOR) UNAUTHORIZED_ACCESS_ERROR)
    (asserts! (not (var-get emergency-system-lockdown)) UNAUTHORIZED_ACCESS_ERROR)
    
    ;; Validate input parameters
    (asserts! (validate-policy-title policy-document-title) INVALID_INPUT_DATA_ERROR)
    (asserts! (validate-content-hash cryptographic-content-hash) INVALID_INPUT_DATA_ERROR)
    (asserts! (validate-timestamp legal-effective-timestamp) INVALID_INPUT_DATA_ERROR)
    (asserts! (validate-optional-timestamp policy-expiration-timestamp) INVALID_INPUT_DATA_ERROR)
    (asserts! (>= legal-effective-timestamp current-blockchain-height) INVALID_POLICY_VERSION_ERROR)
    
    ;; Validate expiration timestamp if provided
    (match policy-expiration-timestamp
      expiration-timestamp (asserts! (> expiration-timestamp legal-effective-timestamp) INVALID_POLICY_VERSION_ERROR)
      true
    )
    
    ;; Ensure policy version doesn't already exist
    (asserts! (is-none (map-get? comprehensive-privacy-policy-registry { policy-version-identifier: new-policy-version-number })) DUPLICATE_POLICY_VERSION_ERROR)
    
    ;; Register the new privacy policy (create safe copy of validated data)
    (let ((safe-expiration-timestamp 
           (match policy-expiration-timestamp
             ts (some ts)
             none)))
      (map-set comprehensive-privacy-policy-registry
        { policy-version-identifier: new-policy-version-number }
        {
          policy-document-title: policy-document-title,
          cryptographic-content-hash: cryptographic-content-hash,
          legal-effective-timestamp: legal-effective-timestamp,
          policy-expiration-timestamp: safe-expiration-timestamp,
          policy-author-principal: tx-sender,
          policy-activation-status: true
        }
      )
    )
    
    ;; Update system state counters
    (var-set total-registered-policies new-policy-version-number)
    (var-set latest-active-policy-version new-policy-version-number)
    
    (ok new-policy-version-number)
  )
)

;; Deactivate a specific policy version
(define-public (deactivate-privacy-policy-version (policy-version-identifier uint))
  (let (
    (existing-policy-record (map-get? comprehensive-privacy-policy-registry { policy-version-identifier: policy-version-identifier }))
  )
    (asserts! (is-eq tx-sender SYSTEM_ADMINISTRATOR) UNAUTHORIZED_ACCESS_ERROR)
    (asserts! (not (var-get emergency-system-lockdown)) UNAUTHORIZED_ACCESS_ERROR)
    
    ;; Validate input parameter
    (asserts! (validate-policy-version policy-version-identifier) INVALID_INPUT_DATA_ERROR)
    
    (match existing-policy-record
      policy-record-data (begin
        (asserts! (get policy-activation-status policy-record-data) PRIVACY_POLICY_NOT_FOUND_ERROR)
        
        (map-set comprehensive-privacy-policy-registry
          { policy-version-identifier: policy-version-identifier }
          (merge policy-record-data { policy-activation-status: false })
        )
        (ok true)
      )
      PRIVACY_POLICY_NOT_FOUND_ERROR
    )
  )
)

;; USER CONSENT MANAGEMENT FUNCTIONS

;; Record user consent for the currently active policy
(define-public (record-user-consent-for-current-policy 
  (legal-consent-classification (string-ascii 20))
  (authorized-processing-activities (list 10 (string-ascii 50)))
  (maximum-retention-duration uint)
)
  (let (
    (current-active-policy-version (var-get latest-active-policy-version))
    (current-blockchain-timestamp block-height)
    (existing-user-consent (map-get? user-consent-tracking-registry { consenting-user-principal: tx-sender, applicable-policy-version: current-active-policy-version }))
  )
    (asserts! (not (var-get emergency-system-lockdown)) UNAUTHORIZED_ACCESS_ERROR)
    (asserts! (> current-active-policy-version u0) PRIVACY_POLICY_NOT_FOUND_ERROR)
    
    ;; Validate input parameters
    (asserts! (validate-consent-classification legal-consent-classification) INVALID_PROCESSING_PURPOSE_ERROR)
    (asserts! (validate-processing-activities authorized-processing-activities) INVALID_PROCESSING_PURPOSE_ERROR)
    (asserts! (validate-retention-duration maximum-retention-duration) INVALID_INPUT_DATA_ERROR)
    
    ;; Verify user doesn't have active consent already
    (match existing-user-consent
      consent-record-data (asserts! (is-eq (get legal-consent-classification consent-record-data) "withdrawn") CONSENT_ALREADY_RECORDED_ERROR)
      true
    )
    
    ;; Store user consent record
    (map-set user-consent-tracking-registry
      { consenting-user-principal: tx-sender, applicable-policy-version: current-active-policy-version }
      {
        consent-recorded-timestamp: current-blockchain-timestamp,
        legal-consent-classification: legal-consent-classification,
        authorized-data-processing-activities: authorized-processing-activities,
        maximum-data-retention-duration: maximum-retention-duration,
        consent-revocation-permitted: true
      }
    )
    
    (ok true)
  )
)

;; Withdraw previously given consent
(define-public (revoke-user-consent-for-current-policy)
  (let (
    (current-active-policy-version (var-get latest-active-policy-version))
    (existing-user-consent (map-get? user-consent-tracking-registry { consenting-user-principal: tx-sender, applicable-policy-version: current-active-policy-version }))
  )
    (asserts! (not (var-get emergency-system-lockdown)) UNAUTHORIZED_ACCESS_ERROR)
    
    ;; Verify consent exists and can be revoked
    (match existing-user-consent
      consent-record-data (begin
        (asserts! (not (is-eq (get legal-consent-classification consent-record-data) "withdrawn")) USER_CONSENT_NOT_FOUND_ERROR)
        (asserts! (get consent-revocation-permitted consent-record-data) UNAUTHORIZED_ACCESS_ERROR)
        
        ;; Update consent status to withdrawn
        (map-set user-consent-tracking-registry
          { consenting-user-principal: tx-sender, applicable-policy-version: current-active-policy-version }
          (merge consent-record-data { legal-consent-classification: "withdrawn" })
        )
        (ok true)
      )
      USER_CONSENT_NOT_FOUND_ERROR
    )
  )
)

;; PERSONAL PRIVACY PREFERENCES MANAGEMENT

;; Update comprehensive user privacy preferences
(define-public (modify-personal-privacy-preferences
  (marketing-communication-consent bool)
  (behavioral-analytics-consent bool)
  (external-data-sharing-consent bool)
  (preferred-retention-duration uint)
  (primary-communication-channel (string-ascii 20))
)
  (begin
    (asserts! (not (var-get emergency-system-lockdown)) UNAUTHORIZED_ACCESS_ERROR)
    (asserts! (verify-user-has-valid-current-consent tx-sender) USER_CONSENT_NOT_FOUND_ERROR)
    
    ;; Validate input parameters
    (asserts! (validate-retention-duration preferred-retention-duration) INVALID_INPUT_DATA_ERROR)
    (asserts! (validate-communication-channel primary-communication-channel) INVALID_DATA_CLASSIFICATION_ERROR)
    
    (map-set individual-privacy-preferences-store
      { preference-owner-principal: tx-sender }
      {
        marketing-communication-consent: marketing-communication-consent,
        behavioral-analytics-consent: behavioral-analytics-consent,
        external-data-sharing-consent: external-data-sharing-consent,
        preferred-data-retention-duration: preferred-retention-duration,
        primary-communication-channel: primary-communication-channel,
        preferences-last-modified-timestamp: block-height
      }
    )
    
    (ok true)
  )
)

;; DATA PROCESSING AUDIT & COMPLIANCE FUNCTIONS

;; Log data processing activity for audit trail
(define-public (log-data-processing-activity
  (subject-user-principal principal)
  (processed-data-classification (string-ascii 30))
  (legal-processing-purpose (string-ascii 50))
  (legal-basis-justification (string-ascii 50))
  (retention-duration-blocks uint)
)
  (let (
    (processing-record-identifier (var-get next-available-processing-record-id))
    (current-blockchain-timestamp block-height)
    (validated-retention-expiry (+ current-blockchain-timestamp retention-duration-blocks))
  )
    (asserts! (is-eq tx-sender SYSTEM_ADMINISTRATOR) UNAUTHORIZED_ACCESS_ERROR)
    (asserts! (not (var-get emergency-system-lockdown)) UNAUTHORIZED_ACCESS_ERROR)
    (asserts! (verify-user-has-valid-current-consent subject-user-principal) USER_CONSENT_NOT_FOUND_ERROR)
    
    ;; Validate input parameters
    (asserts! (validate-principal subject-user-principal) INVALID_INPUT_DATA_ERROR)
    (asserts! (validate-data-classification processed-data-classification) INVALID_DATA_CLASSIFICATION_ERROR)
    (asserts! (validate-string-content legal-processing-purpose) INVALID_INPUT_DATA_ERROR)
    (asserts! (validate-string-content legal-basis-justification) INVALID_INPUT_DATA_ERROR)
    (asserts! (validate-retention-duration retention-duration-blocks) INVALID_INPUT_DATA_ERROR)
    
    ;; Validate retention expiry calculation doesn't overflow
    (asserts! (> validated-retention-expiry current-blockchain-timestamp) INVALID_INPUT_DATA_ERROR)
    
    (map-set data-processing-audit-trail
      { processing-activity-identifier: processing-record-identifier }
      {
        subject-user-principal: subject-user-principal,
        processed-data-classification: processed-data-classification,
        data-processing-legal-purpose: legal-processing-purpose,
        processing-execution-timestamp: current-blockchain-timestamp,
        legal-basis-for-processing: legal-basis-justification,
        data-retention-expiry-timestamp: validated-retention-expiry
      }
    )
    
    (var-set next-available-processing-record-id (+ processing-record-identifier u1))
    (ok processing-record-identifier)
  )
)

;; DATA SUBJECT RIGHTS IMPLEMENTATION

;; Submit request for personal data deletion
(define-public (submit-personal-data-deletion-request (data-categories-for-deletion (list 10 (string-ascii 30))))
  (let (
    (deletion-request-identifier (var-get next-available-deletion-request-id))
    (current-blockchain-timestamp block-height)
  )
    (asserts! (not (var-get emergency-system-lockdown)) UNAUTHORIZED_ACCESS_ERROR)
    
    ;; Validate input parameters
    (asserts! (validate-data-categories data-categories-for-deletion) INVALID_DATA_CLASSIFICATION_ERROR)
    
    (map-set data-subject-deletion-request-queue
      { requesting-user-principal: tx-sender, deletion-request-identifier: deletion-request-identifier }
      {
        deletion-request-submission-timestamp: current-blockchain-timestamp,
        requested-data-categories-for-deletion: data-categories-for-deletion,
        deletion-request-processing-status: "pending",
        deletion-completion-timestamp: none,
        deletion-status-explanation: none
      }
    )
    
    (var-set next-available-deletion-request-id (+ deletion-request-identifier u1))
    (ok deletion-request-identifier)
  )
)

;; Process pending data deletion requests (admin function)
(define-public (process-pending-deletion-request
  (requesting-user-principal principal)
  (deletion-request-identifier uint)
  (new-processing-status (string-ascii 20))
  (status-explanation (optional (string-ascii 200)))
)
  (let (
    ;; Create validated copies of input parameters
    (validated-user-principal requesting-user-principal)
    (validated-request-id deletion-request-identifier)
  )
    (asserts! (is-eq tx-sender SYSTEM_ADMINISTRATOR) UNAUTHORIZED_ACCESS_ERROR)
    (asserts! (not (var-get emergency-system-lockdown)) UNAUTHORIZED_ACCESS_ERROR)
    
    ;; Validate input parameters
    (asserts! (validate-principal validated-user-principal) INVALID_INPUT_DATA_ERROR)
    (asserts! (validate-deletion-request-id validated-request-id) INVALID_INPUT_DATA_ERROR)
    (asserts! (validate-processing-status new-processing-status) INVALID_DATA_CLASSIFICATION_ERROR)
    
    ;; Validate status explanation if provided
    (match status-explanation
      explanation (asserts! (and (> (len explanation) u0) (<= (len explanation) u200)) INVALID_INPUT_DATA_ERROR)
      true
    )
    
    ;; Use a match expression to handle the map lookup and update safely
    (match (map-get? data-subject-deletion-request-queue { requesting-user-principal: validated-user-principal, deletion-request-identifier: validated-request-id })
      deletion-request-data (begin
        (asserts! (is-eq (get deletion-request-processing-status deletion-request-data) "pending") UNAUTHORIZED_ACCESS_ERROR)
        
        ;; Update with validated data - using validated parameters
        (map-set data-subject-deletion-request-queue
          { requesting-user-principal: validated-user-principal, deletion-request-identifier: validated-request-id }
          (merge deletion-request-data {
            deletion-request-processing-status: new-processing-status,
            deletion-completion-timestamp: (if (is-eq new-processing-status "completed") (some block-height) none),
            deletion-status-explanation: status-explanation
          })
        )
        (ok true)
      )
      USER_CONSENT_NOT_FOUND_ERROR
    )
  )
)

;; EMERGENCY SYSTEM CONTROLS

;; Activate emergency system lockdown
(define-public (activate-emergency-system-lockdown)
  (begin
    (asserts! (is-eq tx-sender SYSTEM_ADMINISTRATOR) UNAUTHORIZED_ACCESS_ERROR)
    (var-set emergency-system-lockdown true)
    (ok true)
  )
)

;; Deactivate emergency system lockdown
(define-public (deactivate-emergency-system-lockdown)
  (begin
    (asserts! (is-eq tx-sender SYSTEM_ADMINISTRATOR) UNAUTHORIZED_ACCESS_ERROR)
    (var-set emergency-system-lockdown false)
    (ok true)
  )
)