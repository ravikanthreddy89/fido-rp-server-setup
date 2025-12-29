-- ============================================================================
-- Stored Procedure: populate_sample_data()
-- Description: Populates sample relying parties, configurations, and users
-- ============================================================================

-- Variable declarations at the top
DO $$
DECLARE
  -- Array types for relying parties
  -- Defines the structure for relying party server configuration
  TYPE rp_type AS (
    -- The unique identifier for this relying party (typically domain name or app identifier)
    -- Used to identify the RP in requests from clients
    external_id VARCHAR,

    -- Human-readable name of the relying party (e.g., "My Application", "Example Service")
    -- Displayed to users during WebAuthn registration/authentication
    name VARCHAR,

    -- The origin (protocol + domain) that requests will come from
    -- Must match the exact origin in WebAuthn requests for security
    -- Example: https://example.com
    origin VARCHAR,

    -- URL to the relying party's icon/logo
    -- Used in UI during authentication ceremonies
    icon_url VARCHAR,

    -- Description of the relying party application
    -- Helps identify the RP in admin/management interfaces
    description TEXT,

    -- Challenge timeout in seconds (default: 300)
    -- How long a WebAuthn challenge remains valid before expiring
    -- Prevents replay attacks by invalidating old challenges
    timeout VARCHAR,

    -- Whether user verification is required (true/false)
    -- If true, user must verify their identity (PIN, biometric, etc.)
    -- If false, user presence check is sufficient
    require_user_verification VARCHAR,

    -- Type of authenticator attachment preference (platform/cross-platform/any)
    -- platform: Built-in authenticators (e.g., Windows Hello, Touch ID)
    -- cross-platform: External authenticators (e.g., FIDO2 USB keys, phone)
    authenticator_attachment VARCHAR,

    -- Whether to require resident/discoverable credentials (true/false)
    -- Resident key: Credential is stored on authenticator for usernameless sign-in
    -- Non-resident key: Credential is stored on server, authenticator needs credential ID
    require_resident_key VARCHAR,

    -- Supported public key algorithms as comma-separated values
    -- -7: ES256 (ECDSA with SHA-256, widely supported)
    -- -257: RS256 (RSASSA-PKCS1-v1_5 with SHA-256)
    -- -37: ECDSA with SHA-512
    -- -8: EdDSA
    -- -35: ECDSA with SHA-1 (legacy, not recommended)
    -- -36: Direct (symmetric key, rarely used)
    public_key_alg VARCHAR
  );

  -- Relying Parties Array
  v_relying_parties rp_type[] := ARRAY[
    -- RP 1: Example.com
    ROW(
      'example.com',
      'Example Service',
      'https://example.com',
      'https://example.com/icon.png',
      'RP for example.com web traffic',
      '300',
      'true',
      'platform',
      'true',
      '-7,-257,-37,-8,-35,-36'
    )::rp_type,
    
    -- RP 2: Netlify App
    ROW(
      'pp-signal-sdk-demo.netlify.app',
      'PP Signal netlify app',
      'https://pp-signal-sdk-demo.netlify.app',
      'https://example.com/icon.png',
      'RP for example.com web traffic',
      '600',
      'true',
      'cross-platform',
      'false',
      '-7,-257,-37'
    )::rp_type,
    
    -- RP 3: SaaS App
    ROW(
      'effortless-yeot-a266e9.netlify.app',
      'Saas App',
      'https://effortless-yeot-a266e9.netlify.app/',
      'https://example.com/icon.png',
      'RP for SaaS app web traffic',
      '450',
      'false',
      'platform',
      'true',
      '-7,-257,-37,-8'
    )::rp_type,
    
    -- RP 4: Sowmya Local
    ROW(
      'https://www.sowmya.com',
      'sowmya_local_rp',
      'https://www.sowmya.com',
      'https://example.com/icon.png',
      'RP for local testing',
      '300',
      'true',
      'platform',
      'true',
      '-7,-257,-37,-8,-35,-36'
    )::rp_type
  ];
  
  -- Sample User Values (Optional, can be removed if not needed)
  v_user_external_id VARCHAR := '65fUCTlqPlOSk22tkrkJ2m8I2MEhpF4fCI_pdosMAzk';
  v_user_username VARCHAR := 'testuser4';
  v_user_email VARCHAR := 'testuser4@netlify.app';
  v_user_display_name VARCHAR := 'TestUser4';
  
  -- Variables to store inserted IDs
  v_rp_id BIGINT;
  v_rp_index INT;

BEGIN
  -- ========================================
  -- Insert Sample User
  -- ========================================
  INSERT INTO USERS (id, external_id, username, email, display_name, created_at, updated_at)
  VALUES (0, v_user_external_id, v_user_username, v_user_email, v_user_display_name, NOW(), NOW());

  -- ========================================
  -- Loop through relying parties array
  -- ========================================
  FOR v_rp_index IN 1..array_length(v_relying_parties, 1) LOOP
    -- Insert Relying Party
    INSERT INTO RELYING_PARTIES (external_id, name, origin, icon_url, description)
    VALUES (
      v_relying_parties[v_rp_index].external_id,
      v_relying_parties[v_rp_index].name,
      v_relying_parties[v_rp_index].origin,
      v_relying_parties[v_rp_index].icon_url,
      v_relying_parties[v_rp_index].description
    )
    RETURNING id INTO v_rp_id;
    
    -- Insert Configuration Settings for this RP
    INSERT INTO RELYING_PARTY_CONFIGS (rp_id, setting_key, setting_value)
    VALUES 
      (v_rp_id, 'timeout', v_relying_parties[v_rp_index].timeout),
      (v_rp_id, 'require_user_verification', v_relying_parties[v_rp_index].require_user_verification),
      (v_rp_id, 'authenticator_attachment', v_relying_parties[v_rp_index].authenticator_attachment),
      (v_rp_id, 'require_resident_key', v_relying_parties[v_rp_index].require_resident_key),
      (v_rp_id, 'public_key_alg', v_relying_parties[v_rp_index].public_key_alg);
    
    RAISE NOTICE 'RP % (%) inserted with ID: %', v_rp_index, v_relying_parties[v_rp_index].name, v_rp_id;
  END LOOP;

  -- ========================================
  -- Print Summary
  -- ========================================
  RAISE NOTICE '====================================';
  RAISE NOTICE 'Sample data populated successfully!';
  RAISE NOTICE 'Total RPs inserted: %', array_length(v_relying_parties, 1);
  RAISE NOTICE '====================================';

END $$;

