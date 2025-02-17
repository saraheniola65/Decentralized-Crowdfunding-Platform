;; Campaign Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))

;; Data Variables
(define-data-var campaign-nonce uint u0)

;; Data Maps
(define-map campaigns
  { campaign-id: uint }
  {
    creator: principal,
    title: (string-ascii 100),
    description: (string-utf8 1000),
    funding-goal: uint,
    deadline: uint,
    status: (string-ascii 20)
  }
)

;; Public Functions

;; Create a new campaign
(define-public (create-campaign (title (string-ascii 100)) (description (string-utf8 1000)) (funding-goal uint) (duration uint))
  (let
    (
      (campaign-id (var-get campaign-nonce))
      (deadline (+ block-height duration))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set campaigns
      { campaign-id: campaign-id }
      {
        creator: tx-sender,
        title: title,
        description: description,
        funding-goal: funding-goal,
        deadline: deadline,
        status: "active"
      }
    )
    (var-set campaign-nonce (+ campaign-id u1))
    (ok campaign-id)
  )
)

;; Update campaign status
(define-public (update-campaign-status (campaign-id uint) (new-status (string-ascii 20)))
  (let
    (
      (campaign (unwrap! (map-get? campaigns { campaign-id: campaign-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender (get creator campaign)) err-owner-only)
    (map-set campaigns
      { campaign-id: campaign-id }
      (merge campaign { status: new-status })
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get campaign details
(define-read-only (get-campaign (campaign-id uint))
  (ok (unwrap! (map-get? campaigns { campaign-id: campaign-id }) err-not-found))
)

;; Initialize contract
(begin
  (var-set campaign-nonce u0)
)

