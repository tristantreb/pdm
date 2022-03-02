function [REDCapData] = createREDCapDataTable(nrows)

% createREDCapDataTable - creates the table corresponding to the REDCap
% data format - to be used for initial data conversion

tablevartypes = { 'double'               , 'cell'                    , 'cell'                  , 'cell'            , 'cell'         , ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            , 'cell'         , ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            , 'cell'         , ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            , 'cell'         , ...
                  'cell'                 , ...
                  ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            ,'cell'          , ...
                  ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            , 'cell'         , ...
                  'cell'                 , 'cell'                    , 'cell'                  , ...
                  ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            , ...
                  ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            , ...
                  ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            , ...
                  ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            , ...
                  ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            , ...
                  ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            , ...
                  ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'            , ...
                  ...
                  'cell'                 , 'cell'                    , 'cell'                  , 'cell'             };

tablevarnames = { 'study_id'             , 'redcap_repeat_instrument', 'redcap_repeat_instance', 'hospital'        , 'study_number' , ...
                  'study_date'           , 'patclindate'             , 'dob'                   , 'age'             , 'gender'       , ...
                  'heightcm'             , 'weightkg'                , 'predfev1ltr'           , 'cfgene1'         , 'cfgene2'      , ...
                  'patient_comments'     , 'consent_status'          , 'consent_date'          , 'withdrawal_date' , 'partition_key', ...
                  'patient_info_complete', ...
                  ...
                  'dt_name'              , 'dt_start_date'           , 'dt_stop_date'          , 'dt_comments'     , 'drug_therapy_complete', ...
                  ...
                  'ab_name'              , 'ab_route'                , 'ab_homeiv_s'           , 'ab_start_date'   , 'ab_stop_date' , ...
                  'ab_elective'          , 'ab_comments'             , 'antibiotics_complete'                                       , ...
                  ...
                  'ad_start_date'        , 'ad_stop_date'            , 'ad_comments'           , 'admissions_complete'              , ...
                  ...
                  'cv_location'          , 'cv_attendance_date'      , 'cv_comments'           , 'clinic_visits_complete'           , ...
                  ...
                  'ov_visit_type'        , 'ov_attendance_date'      , 'ov_comments'           , 'other_visits_complete'            , ...
                  ...
                  'up_type_of_contact'   , 'up_contact_date'         , 'up_comments'           , 'unplanned_contact_complete'      , ...
                  ...
                  'crp_date'             , 'crp_level'               , 'crp_comments'          , 'crps_complete'                    , ...
                  ...
                  'pft_date'             , 'pft_fev1'                , 'pft_comments'          , 'pfts_complete'                    , ...
                  ...
                  'mb_name'              , 'mb_date'                 , 'mb_comments'           , 'microbiology_complete'            , ...
                  ...
                  'hw_meas_date'         , 'hw_weight'               , 'hw_comments'           , 'weight_complete'                  };
                  
                  
REDCapData      = table('Size',[nrows size(tablevarnames, 2)], 'VariableTypes', tablevartypes, 'VariableNames', tablevarnames);

end

