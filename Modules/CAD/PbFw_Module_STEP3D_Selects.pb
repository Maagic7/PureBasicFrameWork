
;- ----------------------------------------
;- SELECT Types
;- ----------------------------------------
Enumeration SelectTypes
  ; IN AP242
  ; Enumeration a3m_equivalence_assessment_specification_select ; = Select
      #a3m_equivalence_assessment__by_logical_test
      #a3m_equivalence_assessment__by_numerical_test
  ; EndEnumeration
  ; IN AP242
  ; Enumeration accuracy_associated_target_select ; = Select
      #a3m_equivalence_criteria_representation
      #a3m_equivalence_criterion
      #a3m_equivalence_inspection_result_representation
      #data_equivalence_inspection_result
  ; EndEnumeration
      
  ; IN AP238 Step-NC
  ; Enumeration action_items ; = Select
      #action
      #action_method
      #action_property
      #action_relationship
      #action_request_solution
      #alternate_product_relationship
      #applied_action_assignment
      #applied_classification_assignment
      #applied_person_and_organization_assignment
      #approval_status
      #assembly_component_usage_substitute
      #certification
      #characterized_object
      #class
      #class_system
      #configuration_design
      #configuration_effectivity
      #configuration_item
      #configured_effectivity_assignment
      #contract
      #dimensional_location
      #dimensional_size
      #directed_dimensional_location
      #document_file
      #document_; Enumeration
      #general_property
      #material_designation
      #organization_relationship
      #organizational_project
      #product
      #product_concept
      #product_concept_feature
      #product_concept_feature_association
      #product_concept_feature_category
      #product_concept_feature_category_usage
      #product_definition
      #product_definition_formation
      #product_definition_formation_relationship
      #product_definition_relationship
      #product_definition_substitute
      #property_definition
      #property_definition_relationship
      #security_classification
      #security_classification_level
      #shape_aspect
      #shape_representation
      #versioned_action_request
  ; EndEnumeration
  
  ; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP238 Step-NC/AP242
  ; IN AP242
  ; Enumeration analysed_item ; = Select
      #action_property_representation
      #alternate_product_relationship
      #ascribable_state
      #assembly_component_usage_substitute
      #evidence
      #interface_connection
      #interface_connector_occurrence
      #organization
      #organizational_project_relationship
      #organization_relationship
      #product
      #product_concept
      #product_definition
      #product_definition_context
      #product_definition_formation_relationship
      #product_definition_relationship
      #product_group_relationship
      #product_relationship
      #property_definition
      #property_definition_representation
      #requirement_assignment
      #state_observed
      #state_observed_assignment
      #state_observed_role
      #state_type
      #validation
      #verification
      #verification_relationship
  ; EndEnumeration
      
  ; DIFF IN AP203e2
  ; IN AP203e2/AP242
  ; Enumeration angle_direction_reference_select ; = Select
      #curve
      #direction
      #point_path
  ; EndEnumeration
      
  ; IN AP203e2/AP242
  ; Enumeration angle_direction_reference_with_a2p3d_select ; = Select
      #angle_direction_reference_select
      #axis2_placement_3d
  ; EndEnumeration
      
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; Enumeration annotation_plane_element ; = Select
      #draughting_callout
      #styled_item
  ; EndEnumeration
      
  ; DIFF IN AP203e2; IN AP203e2/AP238 Step-NC/AP242; Enumeration annotation_representation_select ; = Select   draughting_model ; AP238 Step-NC/AP242   presentation_area ; Common   presentation_view ; Common   symbol_representation ; Common; EndEnumeration
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; Enumeration annotation_symbol_occurrence_item ; = Select
      #annotation_symbol
      #defined_symbol
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP214/AP238 Step-NC/AP242; Enumeration annotation_text_occurrence_item ; = Select   annotation_text ; Common   annotation_text_character ; AP203e2/AP214/AP242   composite_text ; Common   defined_character_glyph ; AP214/AP238 Step-NC/AP242   text_literal ; Common; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN Deprecated AP203e1; DIFF IN AP232; Enumeration approval_item ; = Select   action ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   action_directive ; AP203e2/AP214/AP238 Step-NC/AP242   action_method ; AP242   action_method_relationship ; AP242   action_property ; AP214/AP238 Step-NC/AP242   action_property_representation ; AP242   action_request_solution ; AP214/AP238 Step-NC/AP242   alternate_product_relationship ; AP203e2/AP214/AP242   applied_action_assignment ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   applied_action_method_assignment ; AP242   applied_action_request_assignment ; AP242   applied_approval_assignment ; AP242   applied_certification_assignment ; AP232/AP242   applied_classification_assignment ; AP214/AP238 Step-NC/AP242   applied_contract_assignment ; AP242   applied_description_text_assignment ; AP242   applied_description_text_assignment_relationship ; AP242   applied_document_reference ; AP242   applied_document_usage_constraint_assignment ; AP242   applied_effectivity_assignment ; AP232/AP242   applied_event_occurrence_assignment ; AP242   applied_external_identification_assignment ; AP242   applied_identification_assignment ; AP242   applied_ineffectivity_assignment ; AP242   applied_organization_assignment ; AP242   applied_organizational_project_assignment ; AP242   applied_person_and_organization_assignment ; AP242   applied_security_classification_assignment ; AP242   applied_time_interval_assignment ; AP242   applied_usage_right ; AP203e2/AP238 Step-NC/AP242   assembly_component_usage_substitute ; AP203e2/AP214/AP242   breakdown_of ; AP242   certification ; AP203e2/AP214/AP232/AP238 Step-NC/AP242/Deprecated AP203e1   change ; Deprecated AP203e1   change_request ; Deprecated AP203e1   class ; AP214/AP238 Step-NC/AP242   class_system ; AP214/AP238 Step-NC/AP242   configuration_design ; AP214/AP238 Step-NC/AP242   configuration_effectivity ; AP203e2/AP214/AP232/AP238 Step-NC/AP242/Deprecated AP203e1   configuration_item ; AP203e2/AP232/AP238 Step-NC/AP242/Deprecated AP203e1   configured_effectivity_assignment ; AP214/AP238 Step-NC/AP242   contract ; AP203e2/AP214/AP232/AP238 Step-NC/AP242/Deprecated AP203e1   date ; AP203e2/AP238 Step-NC/AP242   date_and_time_assignment ; AP242   date_assignment ; AP242   directed_action ; AP203e2/AP224/AP238 Step-NC/AP242   directed_action_assignment ; AP242   document ; AP203e2/AP238 Step-NC/AP242   document_file ; AP203e2/AP214/AP232/AP242   draughting_model ; AP214/AP242   drawing_revision ; AP214/AP242   effectivity ; AP203e2/AP238 Step-NC/AP242   envelope ; AP242   evaluated_characteristic_of_product_as_individual_test_result ; AP242   evidence ; AP242   exclusive_product_concept_feature_category ; AP242   executed_action ; AP203e2/AP214/AP238 Step-NC/AP242   externally_defined_general_property ; AP242   frozen_assignment ; AP242   general_property ; AP214/AP238 Step-NC/AP242   general_property_relationship ; AP203e2/AP238 Step-NC/AP242   group ; AP203e2/AP238 Step-NC/AP242   group_relationship ; AP203e2/AP238 Step-NC/AP242   identification_assignment_relationship ; AP242   in_zone ; AP242   inclusion_product_concept_feature ; AP242   information_usage_right ; AP203e2/AP238 Step-NC/AP242   interface_connection ; AP242   interface_connector_as_planned ; AP242   interface_connector_as_realized ; AP242   interface_connector_definition ; AP242   interface_connector_design ; AP242   interface_connector_design_to_planned ; AP242   interface_connector_design_to_realized ; AP242   interface_connector_occurrence ; AP242   interface_connector_planned_to_realized ; AP242   interface_connector_version ; AP242   interface_definition_for ; AP242   interface_specification_definition ; AP242   interface_specification_version ; AP242   material_designation ; AP214/AP238 Step-NC/AP242   material_designation_characterization ; AP242   measure_representation_item ; AP242   mechanical_design_geometric_presentation_representation ; AP214/AP242   organization ; AP242   organization_relationship ; AP242   organizational_address ; AP242   organizational_project ; AP214/AP238 Step-NC/AP242   package_product_concept_feature ; AP242   person_and_organization ; AP242   presentation_area ; AP214/AP242   process_plan ; AP242   product ; AP203e2/AP214/AP238 Step-NC/AP242/Deprecated AP203e1   product_class ; AP242   product_concept ; AP214/AP238 Step-NC/AP242   product_concept_feature ; AP214/AP238 Step-NC/AP242   product_concept_feature_association ; AP214/AP238 Step-NC/AP242   product_concept_feature_category ; AP214/AP238 Step-NC/AP242   product_concept_feature_category_usage ; AP214/AP238 Step-NC/AP242   product_definition ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_definition_context ; AP242   product_definition_formation ; AP203e2/AP214/AP224/AP232/AP238 Step-NC/AP242   product_definition_formation_relationship ; AP203e2/AP238 Step-NC/AP242   product_definition_group_assignment ; AP242   product_definition_relationship ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_definition_substitute ; AP214/AP238 Step-NC/AP242   product_definition_usage ; AP242   product_process_plan ; AP242   product_relationship ; AP242   property_definition ; AP214/AP232/AP238 Step-NC/AP242   property_definition_representation ; AP242   representation ; AP203e2/AP238 Step-NC/AP242   representation_item ; AP242   representation_relationship ; AP242   requirement_assignment ; AP203e2/AP238 Step-NC/AP242   requirement_for_action_resource ; AP242   requirement_source ; AP242   resource_property ; AP214/AP242   security_classification ; AP203e2/AP238 Step-NC/AP242/Deprecated AP203e1   shape_aspect_relationship ; AP203e2/AP238 Step-NC/AP242   shape_representation ; AP214/AP238 Step-NC/AP242   start_request ; Deprecated AP203e1   start_work ; Deprecated AP203e1   structured_message ; AP242   validation ; AP242   value_representation_item ; AP242   verification ; AP242   versioned_action_request ; AP203e2/AP214/AP232/AP238 STEP-NC/AP242; EndEnumeration
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; Enumeration area_or_view ; = Select
      #presentation_area
      #presentation_view
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration assignment_object_select ; = Select
      #action_property
      #action_property_representation
      #applied_action_assignment
      #applied_action_method_assignment
      #applied_approval_assignment
      #applied_certification_assignment
      #applied_contract_assignment
      #applied_document_reference
      #applied_document_usage_constraint_assignment
      #applied_effectivity_assignment
      #applied_event_occurrence_assignment
      #applied_ineffectivity_assignment
      #applied_organizational_project_assignment
      #applied_organization_assignment
      #applied_person_and_organization_assignment
      #applied_security_classification_assignment
      #applied_time_interval_assignment
      #applied_usage_right
      #breakdown_of
      #date_and_time_assignment
      #date_assignment
      #directed_action_assignment
      #frozen_assignment
      #material_designation_characterization
      #organizational_address
      #person_and_organization_address
      #product_concept_feature_association
      #product_concept_feature_category_usage
      #property_definition
      #property_definition_representation
      #requirement_assignment
      #requirement_for_action_resource
  ; EndEnumeration
      
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration atom_based_value ; = Select
      #atom_based_tuple
      #maths_atom
  ; EndEnumeration
      
  ; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP238 Step-NC/AP242; Enumeration attribute_classification_item ; = Select   action ; AP242   action_directive ; Common   action_method ; Common   action_method_relationship ; AP242   action_property ; Common   action_property_representation ; Common   action_relationship ; Common   action_request_solution ; Common   action_request_status ; Common   alternate_product_relationship ; Common   applied_action_assignment ; Common   applied_action_method_assignment ; AP242   applied_action_request_assignment ; Common   applied_approval_assignment ; Common   applied_certification_assignment ; Common   applied_document_reference ; Common   applied_document_usage_constraint_assignment ; Common   applied_effectivity_assignment ; Common   applied_event_occurrence_assignment ; Common   applied_external_identification_assignment ; Common   applied_identification_assignment ; Common   applied_organization_assignment ; Common   applied_organizational_project_assignment ; Common   applied_person_and_organization_assignment ; Common   approval ; Common   approval_person_organization ; Common   approval_relationship ; Common   approval_status ; Common   certification ; Common   context_dependent_unit ; Common   contract ; Common   date_and_time_assignment ; Common   date_assignment ; Common   derived_unit ; Common   descriptive_representation_item ; Common   document_file ; Common   document_relationship ; Common   effectivity ; Common   envelope ; AP242   envelope_relationship ; AP242   event_occurrence_relationship ; Common   executed_action ; Common   general_property ; Common   general_property_relationship ; Common   group ; Common   group_relationship ; Common   information_right ; Common   information_usage_right ; Common   interface_connection ; AP242   interface_connector_definition ; AP242   interface_definition_connection ; AP242   interface_specification_definition ; AP242   language ; Common   measure_representation_item ; Common   measure_with_unit ; Common   message_relationship ; AP242   named_unit ; Common   organization_relationship ; Common   organizational_address ; Common   organizational_project_relationship ; Common   person_and_organization ; Common   person_and_organization_address ; Common   product ; Common   product_category ; Common   product_concept ; Common   product_concept_context ; Common   product_definition ; Common   product_definition_context ; Common   product_definition_formation ; Common   product_definition_formation_relationship ; Common   product_definition_relationship ; Common   property_definition ; Common   property_definition_relationship ; Common   property_definition_representation ; Common   representation ; Common   representation_context ; Common   representation_item ; Common   security_classification ; Common   state_observed ; AP242   state_observed_assignment ; AP242   state_observed_relationship ; AP242   state_; Enumeration ; AP242   state_; Enumeration_assignment ; AP242   state_; Enumeration_relationship ; AP242   structured_message ; AP242   time_interval_relationship ; Common   uncertainty_measure_with_unit ; Common   usage_association ; Common   versioned_action_request ; Common; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP214/AP238 Step-NC/AP242; Enumeration attribute_language_item ; = Select   action ; AP214/AP238 Step-NC/AP242   action_directive ; AP214   action_method ; AP214/AP242   action_method_relationship ; AP242   action_property ; AP214   action_relationship ; AP214   actuated_kinematic_pair ; AP242   alternate_product_relationship ; AP203e2/AP214/AP242   application_context ; AP203e2/AP214/AP242   applied_action_assignment ; AP242   applied_action_method_assignment ; AP242   applied_certification_assignment ; AP203e2/AP242   applied_document_reference ; AP203e2/AP238 Step-NC/AP242   applied_document_usage_constraint_assignment ; AP203e2/AP238 Step-NC/AP242   applied_external_identification_assignment ; AP203e2/AP238 Step-NC/AP242   applied_identification_assignment ; AP203e2/AP242   applied_organizational_project_assignment ; AP203e2/AP238 Step-NC/AP242   applied_security_classification_assignment ; AP203e2/AP242   approval ; AP203e2/AP238 Step-NC/AP242   approval_relationship ; Common   approval_status ; AP203e2/AP238 Step-NC/AP242   assembly_component_usage_substitute ; AP203e2/AP214/AP242   attribute_value_assignment ; Common   certification ; Common   certification_; Enumeration ; AP203e2/AP238 Step-NC/AP242   configuration_design ; AP203e2/AP214/AP242   configuration_item ; AP203e2/AP214/AP242   contract ; Common   data_environment ; AP214/AP238 Step-NC/AP242   date_role ; Common   date_time_role ; Common   descriptive_representation_item ; AP203e2/AP214/AP242   document_relationship ; Common   document_usage_role ; AP203e2/AP238 Step-NC/AP242   draughting_title ; AP214/AP242   effectivity ; AP203e2/AP214/AP242   effectivity_relationship ; AP203e2/AP214/AP242   envelope ; AP242   envelope_relationship ; AP242   event_occurrence ; AP203e2/AP214/AP242   evidence ; AP242   external_source ; Common   general_property ; AP203e2/AP214/AP242   general_property_relationship ; AP203e2/AP214/AP242   geometric_representation_item ; AP203e2/AP214/AP242   geometric_tolerance ; AP203e2/AP214/AP242   group ; AP214/AP238 Step-NC/AP242   group_relationship ; AP214/AP238 Step-NC/AP242   identification_role ; Common   information_right ; AP203e2/AP238 Step-NC/AP242   information_usage_right ; AP203e2/AP238 Step-NC/AP242   interface_connection ; AP242   interface_connector_occurrence ; AP242   interface_definition_connection ; AP242   interface_definition_for ; AP242   kinematic_pair ; AP214/AP242   make_from_usage_option ; AP203e2/AP242   mapped_item ; AP203e2/AP214/AP242   message_relationship ; AP242   multi_language_attribute_assignment ; AP203e2/AP238 Step-NC/AP242   name_assignment ; AP214/AP238 Step-NC/AP242   object_role ; AP203e2/AP238 Step-NC/AP242   organization_relationship ; Common   organization_role ; AP203e2/AP214/AP242   organizational_project ; Common   organizational_project_relationship ; Common   organizational_project_role ; AP203e2/AP238 Step-NC/AP242   pair_actuator ; AP214   person_and_organization ; AP203e2/AP238 Step-NC/AP242   person_and_organization_role ; AP203e2/AP214/AP242   presentation_layer_assignment ; AP214/AP242   process_product_association ; AP214/AP242   product ; Common   product_concept ; AP203e2/AP214/AP242   product_concept_feature ; AP214/AP238 Step-NC/AP242   product_concept_feature_association ; AP214/AP238 Step-NC/AP242   product_concept_relationship ; AP203e2/AP214/AP242   product_definition ; Common   product_definition_context ; AP203e2/AP242   product_definition_formation ; Common   product_definition_formation_relationship ; AP203e2/AP214/AP242   product_definition_relationship ; Common   product_definition_shape ; AP203e2/AP242   product_definition_substitute ; AP214/AP238 Step-NC/AP242   product_group ; AP242   product_group_relationship ; AP242   product_related_product_category ; AP203e2/AP214/AP242   property_definition ; AP203e2/AP214/AP242   property_definition_relationship ; AP214/AP238 Step-NC/AP242   representation ; Common   representation_item ; AP242   representation_relationship ; AP214/AP238 Step-NC/AP242   requirement_assignment ; AP242   requirement_for_action_resource ; AP214/AP242   requirement_source ; AP242   resource_property ; AP214/AP242   resource_requirement_; Enumeration ; AP214/AP242   security_classification ; AP203e2/AP214/AP242   security_classification_assignment ; AP203e2/AP242   shape_aspect ; AP203e2/AP214/AP242   shape_aspect_relationship ; AP203e2/AP214/AP242   shape_representation ; AP203e2/AP242   state_observed ; AP242   state_observed_relationship ; AP242   state_; Enumeration ; AP242   state_; Enumeration_relationship ; AP242   structured_message ; AP242   styled_item ; AP214/AP242   time_interval_role ; AP203e2/AP214/AP242   topological_representation_item ; AP203e2/AP214/AP242   uncertainty_measure_with_unit ; AP203e2/AP214/AP242   uncertainty_qualifier ; AP203e2/AP214/AP242   usage_association ; AP203e2/AP238 Step-NC/AP242   validation ; AP242   verification ; AP242   versioned_action_request ; AP214/AP238 Step-NC/AP242   versioned_action_request_relationship ; AP214/AP242; EndEnumeration
  ; IN AP242
  ; Enumeration attribute_select ; = Select
      #product_group_context
      #product_group_purpose
  ; EndEnumeration
      
  ; IN AP203e2/AP214/AP224/AP238 Step-NC/AP242
  ; Enumeration attribute_; Enumeration ; = Select
      #label
      #text
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration axial_geometry_constraint_element ; = Select
      #circle
      #conical_surface
      #cylindrical_surface
      #line
      #plane
      #point
      #revolved_area_solid
      #revolved_face_solid
      #right_circular_cone
      #right_circular_cylinder
      #sphere
      #spherical_surface
      #surface_of_revolution
      #toroidal_surface
      #torus
  ; EndEnumeration
      
  ; Enumeration axis2_placement ; = Select
      #axis2_placement_2d
      #axis2_placement_3d
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration b_spline_or_composite_curve_select ; = Select
      #b_spline_curve
      #composite_curve
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration b_spline_or_rectangular_composite_surface_select ; = Select
      #b_spline_surface
      #rectangular_composite_surface
  ; EndEnumeration
      
  ; IN AP203e2/AP242
  ; Enumeration base_solid_select ; = Select
      #solid_model
      #csg_primitive
      #boolean_result
      ;WHERE WR1: Not  'STEP_MERGED_AP_SCHEMA.PRIMITIVE_2D' IN TypeOf SELF)
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration basis_11_direction_member ; = Select
      #cartesian_11
      #curve_11
      #cylindrical_11
      #point_array
      #polar_11
      #user_defined_11
  ; EndEnumeration
      
  ; DIFF IN AP203e2
  ; IN AP203e2/AP242
  ; Enumeration blend_end_condition_select ; = Select
      #edge_curve
      #point_on_curve
      #vertex
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration boolean_operand ; = Select   boolean_result ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   csg_primitive ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   half_space_2d ; AP242   half_space_solid ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   solid_model ; Common; EndEnumeration
  ; IN AP242
  ; Enumeration boolean_operand_2d ; = Select
      #boolean_result_2d
      #bounded_primitive_2d
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration bounded_primitive_2d ; = Select
      #area_with_outer_boundary
      #circular_area
      #elliptic_area
      #path_area_with_parameters
      #polygonal_area
      #rectangular_area
  ; EndEnumeration
      
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; Enumeration box_characteristic_select ; = Select
      #box_height
      #box_rotate_angle
      #box_slant_angle
      #box_width
  ; EndEnumeration
      
  ; IN AP203e2
  ; Enumeration camera_model_d3_multi_clipping_interection_select ; = Select
      #camera_model_d3_multi_clipping_union
      #plane
  ; EndEnumeration
      
  ; IN AP238 Step-NC/AP242
  ; Enumeration camera_model_d3_multi_clipping_intersection_select ; = Select
      #camera_model_d3_multi_clipping_union
      #plane
  ; EndEnumeration
      
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration camera_model_d3_multi_clipping_union_select ; = Select
      #camera_model_d3_multi_clipping_intersection
      #plane
  ; EndEnumeration
      
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; Enumeration category_usage_item ; = Select
      #product_class
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN Deprecated AP203e1; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242/Deprecated AP203e1; Enumeration certification_item ; = Select   action_method ; AP242   alternate_product_relationship ; AP203e2/AP238 Step-NC/AP242   analysis_assignment ; AP242   applied_action_method_assignment ; AP242   assembly_component_usage ; AP242   evidence ; AP242   executed_action ; AP242   interface_connection ; AP242   interface_connector_version ; AP242   interface_definition_connection ; AP242   interface_specification_version ; AP242   make_from_usage_option ; AP203e2/AP238 Step-NC/AP242   organizational_project ; AP242   product ; AP242   product_definition ; AP214/AP238 Step-NC/AP242   product_definition_formation ; AP203e2/AP214/AP238 Step-NC/AP242   product_definition_formation_relationship ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_definition_occurrence ; AP242   product_definition_occurrence_reference ; AP242   product_definition_relationship ; AP214/AP238 Step-NC/AP242   product_group ; AP242   product_group_relationship ; AP242   product_identification ; AP242   product_relationship ; AP242   requirement_view_definition_relationship ; AP242   supplied_part_relationship ; Deprecated AP203e1; EndEnumeration
  ; IN AP238 Step-NC/AP242
  ; Enumeration chained_representation_link ; = Select
      #mapped_item
      #representation_context
      #representation_relationship
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration change_management_object ; = Select
      #action
      #action_item
      #action_method
      #action_method_relationship
      #action_property
      #action_property_representation
      #action_relationship
      #applied_action_assignment
      #applied_action_method_assignment
      #applied_action_request_assignment
      #applied_approval_assignment
      #applied_certification_assignment
      #applied_contract_assignment
      #applied_document_reference
      #applied_document_usage_constraint_assignment
      #applied_effectivity_assignment
      #applied_event_occurrence_assignment
      #applied_ineffectivity_assignment
      #applied_organizational_project_assignment
      #applied_organization_assignment
      #applied_person_and_organization_assignment
      #applied_security_classification_assignment
      #applied_time_interval_assignment
      #applied_usage_right
      #assembly_component_usage
      #assembly_component_usage_substitute
      #assignment_object_relationship
      #breakdown_of
      #class
      #condition
      #conditional_effectivity
      #configuration_effectivity
      #contract
      #date_and_time_assignment
      #date_assignment
      #directed_action_assignment
      #document_file
      #effectivity
      #event_occurrence
      #exclusive_product_concept_feature_category
      #frozen_assignment
      #general_property_relationship
      #inclusion_product_concept_feature
      #material_designation
      #material_designation_characterization
      #measure_representation_item
      #organization
      #organizational_address
      #organizational_project
      #organizational_project_relationship
      #package_product_concept_feature
      #person
      #person_and_organization
      #person_and_organization_address
      #process_operation
      #process_plan
      #product
      #product_class
      #product_concept_feature
      #product_concept_feature_association
      #product_concept_feature_category
      #product_concept_feature_category_usage
      #product_definition
      #product_definition_formation
      #product_definition_formation_relationship
      #product_definition_group_assignment
      #product_definition_occurrence
      #product_definition_occurrence_reference
      #product_definition_relationship
      #product_definition_substitute
      #product_identification
      #product_process_plan
      #project_item
      #property_definition
      #property_definition_representation
      #representation_relationship
      #requirement_assignment
      #requirement_for_action_resource
      #requirement_view_definition_relationship
      #value_representation_item
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration change_management_object ; = Select
      #action
      #action_item
      #action_method
      #action_method_relationship
      #action_property
      #action_property_representation
      #action_relationship
      #applied_action_assignment
      #applied_action_method_assignment
      #applied_action_request_assignment
      #applied_approval_assignment
      #applied_certification_assignment
      #applied_contract_assignment
      #applied_document_reference
      #applied_document_usage_constraint_assignment
      #applied_effectivity_assignment
      #applied_event_occurrence_assignment
      #applied_ineffectivity_assignment
      #applied_organizational_project_assignment
      #applied_organization_assignment
      #applied_person_and_organization_assignment
      #applied_security_classification_assignment
      #applied_time_interval_assignment
      #applied_usage_right
      #assembly_component_usage
      #assembly_component_usage_substitute
      #assignment_object_relationship
      #breakdown_of
      #class
      #condition
      #conditional_effectivity
      #configuration_effectivity
      #contract
      #date_and_time_assignment
      #date_assignment
      #directed_action_assignment
      #document_file
      #effectivity
      #event_occurrence
      #exclusive_product_concept_feature_category
      #frozen_assignment
      #general_property_relationship
      #inclusion_product_concept_feature
      #material_designation
      #material_designation_characterization
      #measure_representation_item
      #organization
      #organizational_address
      #organizational_project
      #organizational_project_relationship
      #package_product_concept_feature
      #person
      #person_and_organization
      #person_and_organization_address
      #process_operation
      #process_plan
      #product
      #product_class
      #product_concept_feature
      #product_concept_feature_association
      #product_concept_feature_category
      #product_concept_feature_category_usage
      #product_definition
      #product_definition_formation
      #product_definition_formation_relationship
      #product_definition_group_assignment
      #product_definition_occurrence
      #product_definition_occurrence_reference
      #product_definition_relationship
      #product_definition_substitute
      #product_identification
      #product_process_plan
      #project_item
      #property_definition
      #property_definition_representation
      #representation_relationship
      #requirement_assignment
      #requirement_for_action_resource
      #requirement_view_definition_relationship
      #value_representation_item
  ; EndEnumeration
      
  ; IN AP203e2/AP242
  ; Enumeration change_request_item ; = Select
      #product_definition_formation
  ; EndEnumeration
      
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; Enumeration character_spacing_select ; = Select
      #descriptive_measure
      #length_measure
      #measure_with_unit
      #ratio_measure
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration character_style_select ; = Select   character_glyph_style_outline ; AP203e2/AP232/AP238 Step-NC/AP242   character_glyph_style_stroke ; AP203e2/AP232/AP238 Step-NC/AP242   text_style_for_defined_font ; Common; EndEnumeration
  ; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration characterized_action_definition ; = Select   action ; Common   action_method ; Common   action_method_relationship ; AP203e2/AP214/AP238 Step-NC/AP242   action_relationship ; Common; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP224; DIFF IN AP232; Enumeration characterized_definition ; = Select   characterized_item ; AP238 Step-NC/AP242   characterized_object ; Common   characterized_product_definition ; Common   shape_definition ; Common; EndEnumeration
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration characterized_item ; = Select
      #dimensional_size
      #geometric_tolerance
      #item_identified_representation_usage
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP238 Step-NC; DIFF IN AP224; IN AP203e2/AP214/AP224/AP238 Step-NC/AP242; Enumeration characterized_material_property ; = Select   material_property_representation ; Common   product_material_composition_relationship ; AP203e2/AP242; EndEnumeration
  ; IN AP203e2/AP242
  ; Enumeration characterized_product_composition_value ; = Select
      #measure_with_unit
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration characterized_product_definition ; = Select   product_definition ; Common   product_definition_occurrence ; AP238 Step-NC/AP242   product_definition_relationship ; Common   product_definition_relationship_relationship ; AP242; EndEnumeration
  ; IN AP238 Step-NC/AP242
  ; Enumeration characterized_property_representation ; = Select
      #action_property_representation
      #dimensional_characteristic_representation
      #property_definition_representation
      #resource_property_representation
  ; EndEnumeration
      
  ; DIFF IN AP214; IN AP214/AP238 Step-NC/AP242; Enumeration characterized_resource_definition ; = Select   action_resource ; Common   action_resource_relationship ; AP238 Step-NC/AP242   action_resource_requirement ; Common; EndEnumeration
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; Enumeration class_usage_effectivity_context_item ; = Select
      #product_definition
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration classification_item ; = Select   action ; AP203e2/AP214/AP238 Step-NC/AP242   action_directive ; AP203e2/AP214/AP238 Step-NC/AP242   action_directive_relationship ; AP242   action_method ; AP203e2/AP214/AP238 Step-NC/AP242   action_method_relationship ; AP242   action_property ; AP203e2/AP214/AP238 Step-NC/AP242   action_property_representation ; AP242   action_relationship ; AP203e2/AP214/AP238 Step-NC/AP242   action_request_solution ; AP203e2/AP238 Step-NC/AP242   action_request_status ; AP203e2/AP238 Step-NC/AP242   action_resource ; AP238 Step-NC/AP242   action_resource_relationship ; AP238 Step-NC/AP242   action_status ; AP232   address ; AP203e2/AP238 Step-NC/AP242   alternate_product_relationship ; AP203e2/AP238 Step-NC/AP242   alternative_solution_relationship ; AP242   analysis_assignment ; AP242   applied_action_assignment ; AP203e2/AP238 Step-NC/AP242   applied_action_method_assignment ; AP242   applied_action_request_assignment ; AP203e2/AP238 Step-NC/AP242   applied_approval_assignment ; AP203e2/AP238 Step-NC/AP242   applied_certification_assignment ; AP203e2/AP238 Step-NC/AP242   applied_classification_assignment_relationship ; AP242   applied_contract_assignment ; AP203e2/AP238 Step-NC/AP242   applied_date_and_time_assignment ; AP203e2/AP238 Step-NC/AP242   applied_date_assignment ; AP203e2/AP238 Step-NC/AP242   applied_description_text_assignment ; AP242   applied_description_text_assignment_relationship ; AP242   applied_document_reference ; AP203e2/AP238 Step-NC/AP242   applied_document_usage_constraint_assignment ; AP203e2/AP238 Step-NC/AP242   applied_effectivity_assignment ; AP203e2/AP238 Step-NC/AP242   applied_event_occurrence_assignment ; AP203e2/AP238 Step-NC/AP242   applied_external_identification_assignment ; AP203e2/AP238 Step-NC/AP242   applied_external_identification_assignment_relationship ; AP242   applied_identification_assignment ; AP203e2/AP238 Step-NC/AP242   applied_ineffectivity_assignment ; AP242   applied_organization_assignment ; AP203e2/AP238 Step-NC/AP242   applied_organizational_project_assignment ; AP203e2/AP238 Step-NC/AP242   applied_person_and_organization_assignment ; AP203e2/AP238 Step-NC/AP242   applied_security_classification_assignment ; AP203e2/AP238 Step-NC/AP242   applied_time_interval_assignment ; AP242   applied_usage_right ; AP242   approval ; AP203e2/AP232/AP238 Step-NC/AP242   approval_person_organization ; AP203e2/AP238 Step-NC/AP242   approval_relationship ; AP203e2/AP238 Step-NC/AP242   approval_status ; AP203e2/AP214/AP238 Step-NC/AP242   assembly_component_usage_substitute ; AP203e2/AP238 Step-NC/AP242   assignment_object_relationship ; AP242   attribute_language_assignment ; AP242   breakdown_context ; AP242   breakdown_element_realization ; AP242   breakdown_of ; AP242   calendar_date ; AP203e2/AP238 Step-NC/AP242   certification ; AP203e2/AP238 Step-NC/AP242   change_element_sequence ; AP242   change_group ; AP242   characterized_class ; AP203e2/AP242   characterized_object ; AP203e2/AP238 Step-NC/AP242   class ; AP203e2/AP214/AP238 Step-NC/AP242   classified_item ; AP203e2/AP238 Step-NC/AP242   configuration_design ; AP242   configuration_effectivity ; AP242   configuration_item ; AP203e2/AP214/AP238 Step-NC/AP242   configuration_item_relationship ; AP242   context_dependent_unit ; AP203e2/AP238 Step-NC/AP242   contract ; AP203e2/AP214/AP238 Step-NC/AP242   contract_relationship ; AP242   conversion_based_unit ; AP203e2/AP238 Step-NC/AP242   date_and_time ; AP203e2/AP238 Step-NC/AP242   date_and_time_assignment ; AP203e2/AP238 Step-NC/AP242   date_assignment ; AP203e2/AP238 Step-NC/AP242   definitional_representation_relationship ; AP242   derived_unit ; AP203e2/AP238 Step-NC/AP242   descriptive_representation_item ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   directed_action ; AP203e2/AP238 Step-NC/AP242   directed_action_assignment ; AP242   document_file ; AP203e2/AP214/AP238 Step-NC/AP242   document_relationship ; AP203e2/AP238 Step-NC/AP242   document_; Enumeration ; AP214/AP238 Step-NC/AP242   effectivity ; AP203e2/AP214/AP238 Step-NC/AP242   effectivity_relationship ; AP242   envelope ; AP242   envelope_relationship ; AP242   evaluated_characteristic ; AP242   event_occurrence ; AP203e2/AP238 Step-NC/AP242   event_occurrence_relationship ; AP242   evidence ; AP242   executed_action ; AP203e2/AP214/AP238 Step-NC/AP242   externally_defined_representation_with_parameters ; AP224/AP238 Step-NC   feature_definition ; AP214/AP242   general_feature ; AP214/AP242   general_property ; AP203e2/AP214/AP238 Step-NC/AP242   general_property_relationship ; AP203e2/AP238 Step-NC/AP242   generic_property_relationship ; AP242   group ; AP203e2/AP238 Step-NC/AP242   group_relationship ; AP242   identification_assignment ; AP203e2/AP238 Step-NC/AP242   identification_assignment_relationship ; AP242   in_zone ; AP242   information_right ; AP203e2/AP238 Step-NC/AP242   information_usage_right ; AP203e2/AP238 Step-NC/AP242   interface_connection ; AP242   interface_connector_as_planned ; AP242   interface_connector_as_realized ; AP242   interface_connector_design ; AP242   interface_connector_design_to_planned ; AP242   interface_connector_design_to_realized ; AP242   interface_connector_occurrence ; AP242   interface_connector_planned_to_realized ; AP242   interface_definition_connection ; AP242   interface_definition_for ; AP242   language ; AP203e2/AP238 Step-NC/AP242   link_motion_relationship ; AP242   local_time ; AP242   location ; AP242   location_relationship ; AP242   material_designation ; AP214/AP238 Step-NC/AP242   material_designation_characterization ; AP242   measure_qualification ; AP242   measure_representation_item ; AP203e2/AP238 Step-NC/AP242   measure_with_unit ; AP203e2/AP238 Step-NC/AP242   message_relationship ; AP242   multi_language_attribute_assignment ; AP203e2/AP238 Step-NC/AP242   named_unit ; AP203e2/AP238 Step-NC/AP242   organization ; AP203e2/AP238 Step-NC/AP242   organization_relationship ; AP203e2/AP238 Step-NC/AP242   organizational_address ; AP203e2/AP238 Step-NC/AP242   organizational_project ; AP203e2/AP214/AP238 Step-NC/AP242   organizational_project_relationship ; AP203e2/AP238 Step-NC/AP242   person ; AP203e2/AP238 Step-NC/AP242   person_and_organization ; AP242   person_and_organization_address ; AP203e2/AP238 Step-NC/AP242   plus_minus_tolerance ; AP214/AP242   process_operation ; AP214/AP242   process_plan ; AP242   process_product_association ; AP242   product ; AP203e2/AP214/AP238 Step-NC/AP242   product_concept ; AP203e2/AP214/AP238 Step-NC/AP242   product_concept_context ; AP242   product_concept_feature ; AP214/AP238 Step-NC/AP242   product_concept_feature_association ; AP242   product_concept_feature_category ; AP214/AP238 Step-NC/AP242   product_concept_feature_category_usage ; AP242   product_concept_relationship ; AP242   product_definition ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_definition_context ; AP203e2/AP238 Step-NC/AP242   product_definition_formation ; AP203e2/AP214/AP238 Step-NC/AP242   product_definition_formation_relationship ; AP203e2/AP238 Step-NC/AP242   product_definition_relationship ; AP203e2/AP214/AP238 Step-NC/AP242   product_definition_usage ; AP242   product_definition_usage_relationship ; AP242   product_design_to_individual ; AP242   product_design_version_to_individual ; AP242   product_group ; AP242   product_group_membership ; AP242   product_group_relationship ; AP242   product_process_plan ; AP242   product_relationship ; AP242   property_definition ; AP203e2/AP214/AP238 Step-NC/AP242   property_definition_representation ; AP203e2/AP238 Step-NC/AP242   representation ; AP203e2/AP238 Step-NC/AP242   representation_context ; AP203e2/AP238 Step-NC/AP242   representation_item ; AP203e2/AP238 Step-NC/AP242   representation_relationship ; AP242   requirement_assignment ; AP242   requirement_for_action_resource ; AP242   requirement_source ; AP242   resource_property ; AP214/AP242   retention ; AP242   satisfies_requirement ; AP242   security_classification ; AP203e2/AP238 Step-NC/AP242   security_classification_level ; AP214/AP238 Step-NC/AP242   shape_aspect ; AP214/AP238 Step-NC/AP242   shape_aspect_relationship ; AP242   shape_feature_definition_relationship ; AP242   state_definition_to_state_assignment_relationship ; AP242   state_observed ; AP242   state_observed_assignment ; AP242   state_observed_relationship ; AP242   state_observed_role ; AP242   state_; Enumeration ; AP242   state_; Enumeration_assignment ; AP242   state_; Enumeration_relationship ; AP242   structured_message ; AP242   time_interval_relationship ; AP242   ; Enumeration_qualifier ; AP242   uncertainty_measure_with_unit ; AP203e2/AP238 Step-NC/AP242   usage_association ; AP203e2/AP238 Step-NC/AP242   validation ; AP242   verification ; AP242   versioned_action_request ; AP203e2/AP214/AP238 Step-NC/AP242   versioned_action_request_relationship ; AP242; EndEnumeration
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration classified_item ; = Select
      #product
      #product_definition
      #product_definition_formation
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration closed_or_open_shell_select ; = Select
      #closed_shell
      #open_shell
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration compound_inner_area_boundary ; = Select
      #set_inner_area_boundary
  ; EndEnumeration
      
  ; DIFF IN AP232; Enumeration compound_item_definition ; = Select   list_representation_item ; Common   set_representation_item ; AP203e2/AP214/AP224/AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration configuration_design_item ; = Select   product_definition ; Common   product_definition_formation ; Common   product_definition_occurrence ; AP238 STEP-NC/AP242; EndEnumeration
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; Enumeration configured_effectivity_context_item ; = Select
      #product_concept_feature_association
  ; EndEnumeration
  ; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP214/AP238 Step-NC/AP242; Enumeration configured_effectivity_item ; = Select   action_relationship ; AP214/AP238 Step-NC/AP242   process_plan ; AP214/AP242   product_definition ; Common   product_process_plan ; AP214/AP242; EndEnumeration
      
  ; IN AP242
  ; Enumeration connected_edge_with_length_set_items ; = Select
      #connected_edge_set
      #path
      #vertex_on_edge
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration constraint_group_member ; = Select
      #explicit_constraint
      #simultaneous_constraint_group
  ; EndEnumeration
  
  
  ; IN AP203e2
  ; Enumeration constructive_geometry_representation_or_shape_represenation ; = Select
      #constructive_geometry_representation
      #shape_representation
  ; EndEnumeration
      
  ; IN AP238 Step-NC/AP242
  ; Enumeration constructive_geometry_representation_or_shape_representation ; = Select
      #constructive_geometry_representation
      #shape_representation
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN Deprecated AP203e1; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242/Deprecated AP203e1; Enumeration contract_item ; = Select   action ; AP232   action_directive ; AP203e2/AP238 Step-NC/AP242   action_method ; AP242   action_method_relationship ; AP242   alternate_product_relationship ; AP203e2/AP238 Step-NC/AP242   applied_action_method_assignment ; AP242   applied_classification_assignment ; AP242   applied_description_text_assignment ; AP242   applied_external_identification_assignment ; AP242   applied_identification_assignment ; AP242   applied_organization_assignment ; AP242   applied_person_and_organization_assignment ; AP242   directed_action ; AP203e2/AP238 Step-NC/AP242   drawing_revision ; AP214/AP242   executed_action ; AP203e2/AP214/AP242   information_usage_right ; AP203e2/AP238 Step-NC/AP242   interface_connector_as_planned ; AP242   interface_connector_as_realized ; AP242   interface_connector_design ; AP242   organization ; AP203e2/AP238 Step-NC/AP242   organizational_project ; AP242   person_and_organization ; AP203e2/AP238 Step-NC/AP242   product ; AP203e2/AP238 Step-NC/AP242   product_definition ; AP232/AP242   product_definition_context ; AP242   product_definition_formation ; Common   product_definition_formation_relationship ; AP242   product_definition_relationship ; AP242   product_definition_with_associated_documents ; AP232   product_group ; AP242   product_group_relationship ; AP242   product_identification ; AP242   property_definition ; AP232   requirement_assignment ; AP242   requirement_source ; AP242   security_classification ; AP242   structured_message ; AP242   validation ; AP242   verification ; AP242   versioned_action_request ; AP242; EndEnumeration
  ; Enumeration csg_2d_area_select ; = Select
      #axis2_placement_2d
      #csg_primitive_solid_2d
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration csg_2d_shape_select ; = Select
      #axis2_placement_2d
      #csg_solid_2d
      #mapped_item
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration csg_primitive ; = Select   block ; Common   bounded_primitive_2d ; AP242   cyclide_segment_solid ; AP238 Step-NC/AP242   eccentric_cone ; AP238 Step-NC/AP242   ellipsoid ; AP238 Step-NC/AP242   faceted_primitive ; AP238 Step-NC/AP242   rectangular_pyramid ; AP238 Step-NC/AP242   right_angular_wedge ; Common   right_circular_cone ; Common   right_circular_cylinder ; Common   sphere ; Common   torus ; Common; EndEnumeration
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; Enumeration csg_select ; = Select
      #boolean_result
      #csg_primitive
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration csg_select_2d ; = Select
      #boolean_result_2d
      #bounded_primitive_2d
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration current_element_assignment_select ; = Select
      #add_element
      #modify_element
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration curve_font_or_scaled_curve_font_select ; = Select   curve_style_font_and_scaling ; AP203e2/AP238 Step-NC/AP242   curve_style_font_select ; Common; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP224; DIFF IN AP232; Enumeration curve_on_surface ; = Select   composite_curve_on_surface ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   pcurve ; Common   surface_curve ; Common; EndEnumeration
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration curve_or_annotation_curve_occurrence ; = Select
      #annotation_curve_occurrence
      #curve
  ; EndEnumeration
  ; IN AP238 Step-NC/AP242
  ; Enumeration curve_or_curve_set ; = Select
      #curve
      #geometric_curve_set
  ; EndEnumeration
      
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; Enumeration curve_or_render ; = Select
      #curve_style
      #curve_style_rendering
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration curve_or_surface_constraint_element ; = Select
      #curve
      #surface
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration curve_style_font_select ; = Select   curve_style_font ; Common   externally_defined_curve_font ; AP203e2/AP214/AP238 Step-NC/AP242   pre_defined_curve_font ; Common; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN Deprecated AP203e1; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242/Deprecated AP203e1; Enumeration date_and_time_item ; = Select   action ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   action_directive ; AP203e2/AP214/AP238 Step-NC/AP242   action_method ; AP214/AP238 Step-NC/AP242   action_property ; AP214/AP238 Step-NC/AP242   action_relationship ; AP214/AP238 Step-NC/AP242   action_request_solution ; AP214/AP238 Step-NC/AP242   alternate_product_relationship ; AP214/AP238 Step-NC/AP242   analysis_assignment ; AP242   applied_action_assignment ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   applied_action_method_assignment ; AP242   applied_certification_assignment ; AP242   applied_classification_assignment ; AP214/AP238 Step-NC/AP242   applied_contract_assignment ; AP232/AP242   applied_document_reference ; AP242   applied_document_usage_constraint_assignment ; AP242   applied_effectivity_assignment ; AP242   applied_event_occurrence_assignment ; AP242   applied_identification_assignment ; AP242   applied_organization_assignment ; AP203e2/AP214/AP238 Step-NC/AP242   applied_organizational_project_assignment ; AP242   applied_person_and_organization_assignment ; AP203e2/AP214/AP238 Step-NC/AP242   applied_security_classification_assignment ; AP203e2/AP232/AP238 Step-NC/AP242   applied_usage_right ; AP242   approval ; AP242   approval_person_organization ; Common   approval_status ; AP214/AP238 Step-NC/AP242   ascribable_state ; AP242   assembly_component_usage_substitute ; AP214/AP238 Step-NC/AP242   certification ; Common   change ; Deprecated AP203e1   change_request ; Deprecated AP203e1   class ; AP214/AP238 Step-NC/AP242   class_system ; AP214/AP238 Step-NC/AP242   configuration_design ; AP214/AP238 Step-NC/AP242   configuration_item ; AP214/AP238 Step-NC/AP242   configured_effectivity_assignment ; AP214/AP238 Step-NC/AP242   contract ; Common   data_equivalence_definition ; AP242   data_quality_definition ; AP242   date_and_time_assignment ; AP242   date_assignment ; AP242   directed_action ; AP203e2/AP238 Step-NC/AP242   document ; AP203e2/AP238 Step-NC/AP242   document_file ; AP203e2/AP214/AP238 Step-NC/AP242   draughting_model ; AP214/AP242   drawing_revision ; AP214/AP242   effectivity ; AP214/AP238 Step-NC/AP242   envelope ; AP242   event_occurrence ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   evidence ; AP242   executed_action ; AP203e2/AP214/AP238 Step-NC/AP242   general_property ; AP214/AP238 Step-NC/AP242   general_property_relationship ; AP242   information_usage_right ; AP203e2/AP238 Step-NC/AP242   interface_connection ; AP242   interface_connector_as_planned ; AP242   interface_connector_as_realized ; AP242   interface_connector_design_to_planned ; AP242   interface_connector_design_to_realized ; AP242   interface_connector_occurrence ; AP242   interface_connector_planned_to_realized ; AP242   interface_definition_connection ; AP242   interface_definition_for ; AP242   machining_operation ; AP238 Step-NC   machining_process_executable ; AP238 Step-NC   machining_toolpath ; AP238 Step-NC   material_designation ; AP214/AP238 Step-NC/AP242   mechanical_design_geometric_presentation_representation ; AP214/AP242   organization_relationship ; AP214/AP238 Step-NC/AP242   organizational_address ; AP242   organizational_project ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   person ; AP242   person_and_organization ; AP214/AP238 Step-NC/AP242   presentation_area ; AP214/AP242   product ; AP214/AP238 Step-NC/AP242   product_concept ; AP214/AP238 Step-NC/AP242   product_concept_feature ; AP214/AP238 Step-NC/AP242   product_concept_feature_association ; AP214/AP238 Step-NC/AP242   product_concept_feature_category ; AP214/AP238 Step-NC/AP242   product_concept_feature_category_usage ; AP214/AP238 Step-NC/AP242   product_definition ; Common   product_definition_context ; AP242   product_definition_formation ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_definition_formation_relationship ; AP214/AP238 Step-NC/AP242   product_definition_relationship ; AP203e2/AP214/AP238 Step-NC/AP242   product_definition_substitute ; AP214/AP238 Step-NC/AP242   product_group ; AP242   product_group_membership ; AP242   product_group_relationship ; AP242   product_identification ; AP242   property_definition ; AP214/AP238 Step-NC/AP242   property_definition_representation ; AP242   representation ; AP232/AP242   requirement_assignment ; AP242   requirement_for_action_resource ; AP214/AP242   requirement_source ; AP242   resource_property ; AP214/AP242   rule_action ; AP203e2/AP242   security_classification ; Common   security_classification_level ; AP214/AP238 Step-NC/AP242   shape_representation ; AP214/AP238 Step-NC/AP242   start_request ; Deprecated AP203e1   start_work ; Deprecated AP203e1   state_observed ; AP242   state_observed_assignment ; AP242   state_observed_relationship ; AP242   state_; Enumeration ; AP242   state_; Enumeration_assignment ; AP242   state_; Enumeration_relationship ; AP242   structured_message ; AP242   validation ; AP242   verification ; AP242   verification_relationship ; AP242   versioned_action_request ; AP203e2/AP214/AP232/AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration date_item ; = Select   action ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   action_directive ; AP203e2/AP214/AP238 Step-NC/AP242   action_method ; AP214/AP238 Step-NC/AP242   action_property ; AP214/AP238 Step-NC/AP242   action_relationship ; AP214/AP238 Step-NC/AP242   action_request_solution ; AP214/AP238 Step-NC/AP242   alternate_product_relationship ; AP214/AP238 Step-NC/AP242   analysis_assignment ; AP242   applied_action_assignment ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   applied_action_method_assignment ; AP242   applied_certification_assignment ; AP242   applied_classification_assignment ; AP214/AP238 Step-NC/AP242   applied_contract_assignment ; AP232/AP242   applied_document_reference ; AP242   applied_document_usage_constraint_assignment ; AP242   applied_effectivity_assignment ; AP242   applied_event_occurrence_assignment ; AP242   applied_identification_assignment ; AP242   applied_organization_assignment ; AP203e2/AP214/AP238 Step-NC/AP242   applied_organizational_project_assignment ; AP242   applied_person_and_organization_assignment ; AP203e2/AP214/AP238 Step-NC/AP242   applied_security_classification_assignment ; AP203e2/AP232/AP238 Step-NC/AP242   applied_usage_right ; AP242   approval ; AP242   approval_person_organization ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   approval_status ; AP214/AP238 Step-NC/AP242   ascribable_state ; AP242   assembly_component_usage_substitute ; AP214/AP238 Step-NC/AP242   certification ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   class ; AP214/AP238 Step-NC/AP242   class_system ; AP214/AP238 Step-NC/AP242   configuration_design ; AP214/AP238 Step-NC/AP242   configuration_item ; AP214/AP238 Step-NC/AP242   configured_effectivity_assignment ; AP214/AP238 Step-NC/AP242   contract ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   data_equivalence_definition ; AP242   data_quality_definition ; AP242   date_and_time_assignment ; AP242   date_assignment ; AP242   directed_action ; AP203e2/AP224/AP238 Step-NC/AP242   document ; AP203e2/AP224/AP238 Step-NC/AP242   document_file ; AP203e2/AP214/AP238 Step-NC/AP242   draughting_model ; AP214/AP242   drawing_revision ; AP214/AP242   effectivity ; AP214/AP238 Step-NC/AP242   envelope ; AP242   event_occurrence ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   evidence ; AP242   executed_action ; AP203e2/AP214/AP238 Step-NC/AP242   general_property ; AP214/AP238 Step-NC/AP242   general_property_relationship ; AP242   information_usage_right ; AP203e2/AP238 Step-NC/AP242   interface_connection ; AP242   interface_connector_as_planned ; AP242   interface_connector_as_realized ; AP242   interface_connector_design_to_planned ; AP242   interface_connector_design_to_realized ; AP242   interface_connector_occurrence ; AP242   interface_connector_planned_to_realized ; AP242   interface_definition_connection ; AP242   interface_definition_for ; AP242   material_designation ; AP214/AP238 Step-NC/AP242   mechanical_design_geometric_presentation_representation ; AP214/AP242   organization_relationship ; AP214/AP238 Step-NC/AP242   organizational_address ; AP242   organizational_project ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   person ; AP242   person_and_organization ; AP214/AP238 Step-NC/AP242   presentation_area ; AP214/AP242   product ; AP214/AP238 Step-NC/AP242   product_concept ; AP214/AP238 Step-NC/AP242   product_concept_feature ; AP214/AP238 Step-NC/AP242   product_concept_feature_association ; AP214/AP238 Step-NC/AP242   product_concept_feature_category ; AP214/AP238 Step-NC/AP242   product_concept_feature_category_usage ; AP214/AP238 Step-NC/AP242   product_definition ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_definition_context ; AP242   product_definition_formation ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_definition_formation_relationship ; AP214/AP238 Step-NC/AP242   product_definition_relationship ; AP203e2/AP214/AP238 Step-NC/AP242   product_definition_substitute ; AP214/AP238 Step-NC/AP242   product_group ; AP242   product_group_membership ; AP242   product_group_relationship ; AP242   product_identification ; AP242   property_definition ; AP214/AP238 Step-NC/AP242   property_definition_representation ; AP242   representation ; AP232/AP242   requirement_assignment ; AP242   requirement_for_action_resource ; AP214/AP242   requirement_source ; AP242   resource_property ; AP214/AP242   security_classification ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   security_classification_level ; AP214/AP238 Step-NC/AP242   shape_representation ; AP214/AP238 Step-NC/AP242   state_observed ; AP242   state_observed_assignment ; AP242   state_observed_relationship ; AP242   state_; Enumeration ; AP242   state_; Enumeration_assignment ; AP242   state_; Enumeration_relationship ; AP242   structured_message ; AP242   validation ; AP242   verification ; AP242   verification_relationship ; AP242   versioned_action_request ; Common
  ; DIFF IN AP224; Enumeration date_time_or_event_occurrence ; = Select   date_time_select ; Common   event_occurrence ; AP203e2/AP214/AP232/AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP224; DIFF IN AP232; Enumeration date_time_select ; = Select   date ; Common   date_and_time ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   local_time ; AP203e2/AP214/AP232/AP238 STEP-NC/AP242; EndEnumeration
  ; IN AP238 Step-NC/AP242
  ; Enumeration datum_or_common_datum ; = Select
      #common_datum_list
      #datum
  ; EndEnumeration
      
  ; IN AP238 Step-NC/AP242
  ; Enumeration datum_reference_modifier ; = Select
      #datum_reference_modifier_with_value
      #simple_datum_reference_modifier
  ; EndEnumeration
      
  ; IN AP238 Step-NC/AP242
  ; Enumeration datum_system_or_reference ; = Select
      #datum_reference
      #datum_system
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP214/AP232/AP238 Step-NC/AP242; Enumeration defined_glyph_select ; = Select   externally_defined_character_glyph ; Common   pre_defined_character_glyph ; AP232/AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration defined_symbol_select ; = Select   externally_defined_symbol ; Common   pre_defined_symbol ; AP203e2/AP214/AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration derived_property_select ; = Select   action_property ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   dimensional_location ; AP238 Step-NC/AP242   dimensional_size ; AP238 Step-NC/AP242   geometric_tolerance ; AP238 Step-NC/AP242   property_definition ; Common   resource_property ; AP214/AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration description_attribute_select ; = Select   action_request_solution ; Common   application_context ; Common   approval_role ; Common   configuration_design ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   context_dependent_shape_representation ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   date_role ; Common   date_time_role ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   effectivity ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   external_source ; Common   organization_role ; Common   organizational_project ; AP238 Step-NC/AP242   person_and_organization ; Common   person_and_organization_role ; Common   property_definition_representation ; Common   representation ; Common; EndEnumeration
  ; IN AP242
  ; Enumeration description_item ; = Select
      #action
      #action_directive
      #action_directive_relationship
      #action_method
      #action_method_relationship
      #action_property
      #action_property_representation
      #action_relationship
      #address
      #alternate_product_relationship
      #alternative_solution_relationship
      #analysis_representation_context
      #applied_action_assignment
      #applied_action_method_assignment
      #applied_action_request_assignment
      #applied_approval_assignment
      #applied_certification_assignment
      #applied_classification_assignment
      #applied_classification_assignment_relationship
      #applied_contract_assignment
      #applied_description_text_assignment
      #applied_description_text_assignment_relationship
      #applied_document_reference
      #applied_document_usage_constraint_assignment
      #applied_effectivity_assignment
      #applied_event_occurrence_assignment
      #applied_external_identification_assignment
      #applied_external_identification_assignment_relationship
      #applied_identification_assignment
      #applied_ineffectivity_assignment
      #applied_location_assignment
      #applied_location_representation_assignment
      #applied_organizational_project_assignment
      #applied_organization_assignment
      #applied_person_and_organization_assignment
      #applied_security_classification_assignment
      #applied_state_observed_assignment
      #applied_state_type_assignment
      #applied_time_interval_assignment
      #applied_usage_right
      #approval
      #approval_relationship
      #ascribable_state
      #ascribable_state_relationship
      #assembly_component_usage_substitute
      #assignment_object_relationship
      #breakdown_element_group_assignment
      #certification
      #change_element_sequence
      #change_group
      #configuration_design
      #configuration_effectivity
      #configuration_item
      #configuration_item_relationship
      #contract
      #contract_relationship
      #data_environment
      #date_and_time_assignment
      #date_assignment
      #directed_action_assignment
      #document_file
      #document_relationship
      #effectivity
      #effectivity_relationship
      #envelope
      #envelope_relationship
      #evaluated_characteristic
      #event_occurrence
      #event_occurrence_relationship
      #exclusive_product_concept_feature_category
      #general_property
      #general_property_relationship
      #generic_property_relationship
      #geometric_item_specific_usage
      #global_uncertainty_assigned_context
      #global_unit_assigned_context
      #group
      #group_relationship
      #location
      #location_relationship
      #material_designation_characterization
      #measure_qualification
      #measure_with_unit
      #message_relationship
      #organization
      #organizational_address
      #organizational_project
      #organizational_project_relationship
      #organization_relationship
      #organization_type
      #package_product_concept_feature
      #person
      #person_and_organization
      #person_and_organization_address
      #process_operation
      #process_plan
      #process_product_association
      #product
      #product_concept
      #product_concept_context
      #product_concept_feature
      #product_concept_feature_association
      #product_concept_feature_category
      #product_concept_feature_category_usage
      #product_concept_relationship
      #product_definition
      #product_definition_context
      #product_definition_formation
      #product_definition_formation_relationship
      #product_definition_group_assignment
      #product_definition_relationship
      #product_definition_usage
      #product_definition_usage_relationship
      #product_group_membership
      #product_group_relationship
      #product_process_plan
      #product_relationship
      #property_definition
      #property_definition_representation
      #representation
      #representation_context
      #representation_item
      #representation_relationship
      #requirement_for_action_resource
      #retention
      #satisfies_requirement
      #security_classification
      #shape_aspect
      #shape_aspect_relationship
      #shape_feature_definition
      #shape_feature_definition_relationship
      #state_definition_to_state_assignment_relationship
      #state_observed
      #state_observed_assignment
      #state_observed_relationship
      #state_observed_role
      #state_type
      #state_type_assignment
      #state_type_relationship
      #state_type_role
      #structured_message
      #time_interval
      #time_interval_relationship
      #uncertainty_measure_with_unit
      #uncertainty_qualifier
      #usage_association
      #verification_relationship
      #versioned_action_request
      #versioned_action_request_relationship
  ; EndEnumeration
      
  ; IN AP203e2/AP214/AP224/AP238 Step-NC/AP242
  ; Enumeration dimensional_characteristic ; = Select
      #dimensional_location
      #dimensional_size
  ; EndEnumeration
      
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; Enumeration direction_count_select ; = Select
      #u_direction_count
      #v_direction_count
  ; EndEnumeration
      
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration document_identifier_assigned_item ; = Select
      #document
  ; EndEnumeration
      
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; DIFF IN AP224
  ; DIFF IN AP240
  ; DIFF IN Deprecated AP203e1
  ; DIFF IN AP232
  ; Enumeration draughting_approval_item ; = Select
      #drawing_revision
      #drawing_sheet_revision
  ; EndEnumeration
      
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP232
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; Enumeration draughting_model_item_association_select ; = Select
      #annotation_occurrence
      #draughting_callout
  ; EndEnumeration
      
  ; DIFF IN AP238 Step-NC; IN AP238 Step-NC/AP242
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration draughting_model_item_select ; = Select
      #axis2_placement
      #camera_model
      #draughting_callout
      #mapped_item
      #styled_item
  ; EndEnumeration
      
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration draughting_subfigure_representation_item ; = Select
      #annotation_occurrence
      #axis2_placement
      #draughting_callout
  ; EndEnumeration
      
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration draughting_symbol_representation_item ; = Select
      #annotation_curve_occurrence
      #annotation_fill_area_occurrence
      #annotation_symbol_occurrence
      #annotation_text_occurrence
      #axis2_placement
  ; EndEnumeration
      
  ; IN AP203e2/AP214/AP232/AP242
  ; Enumeration draughting_titled_item ; = Select
      #drawing_revision
      #drawing_sheet_revision
  ; EndEnumeration
      
  ; IN AP238 Step-NC/AP242
  ; Enumeration edge_or_curve ; = Select
      #curve
      #edge
  ; EndEnumeration
      
  ; IN AP232
  ; Enumeration effectivity_context_item ; = Select
      #organization
      #product_definition_formation
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP240; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP240/AP242
  ; IN AP242
  ; Enumeration equivalence_detected_difference_select ; = Select
      #a3ms_inspected_equivalence_element_select
      #area_measure
      #assembly_component_usage
      #binary_assembly_constraint
      #cartesian_point
      #connected_face_set
      #context_dependent_shape_representation
      #count_measure
      #edge
      #face
      #length_measure
      #multi_level_reference_designator
      #point_on_curve
      #point_on_surface
      #volume_measure
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration equivalence_measured_value_select ; = Select
      #a3ma_length_measure_and_context_dependent_measure_pair
      #area_measure
      #boolean_value
      #context_dependent_measure
      #length_measure
      #plane_angle_measure
      #volume_measure
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration equivalence_product_data_select ; = Select
      #product_definition_or_reference
      #product_definition_relationship
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration event_occurrence_item ; = Select   action ; AP214/AP238 Step-NC/AP242   action_directive ; AP214/AP238 Step-NC/AP242   action_method ; AP214/AP238 Step-NC/AP242   action_property ; AP214/AP238 Step-NC/AP242   action_relationship ; AP214   action_request_solution ; AP214/AP238 Step-NC/AP242   alternate_product_relationship ; AP214/AP238 Step-NC/AP242   applied_action_assignment ; AP214/AP238 Step-NC/AP242   applied_classification_assignment ; AP214/AP238 Step-NC/AP242   applied_person_and_organization_assignment ; AP214   approval_status ; AP214   assembly_component_usage_substitute ; AP214/AP238 Step-NC/AP242   certification ; AP214/AP238 Step-NC/AP242   class ; AP214/AP238 Step-NC/AP242   class_system ; AP214/AP238 Step-NC/AP242   configuration_design ; AP214/AP238 Step-NC/AP242   configuration_effectivity ; AP214/AP238 Step-NC/AP242   configuration_item ; AP214/AP238 Step-NC/AP242   configured_effectivity_assignment ; AP214/AP238 Step-NC/AP242   contract ; AP214/AP238 Step-NC/AP242   document_file ; AP214   draughting_model ; AP214/AP242   drawing_revision ; AP214/AP242   executed_action ; AP214/AP238 Step-NC/AP242   general_organizational_data_select ; AP242   general_property ; AP214/AP238 Step-NC/AP242   material_designation ; AP214/AP238 Step-NC/AP242   mechanical_design_geometric_presentation_representation ; AP214/AP242   organization_relationship ; AP214/AP238 Step-NC/AP242   organizational_project ; Common   person_and_organization ; AP214/AP238 Step-NC/AP242   presentation_area ; AP214/AP242   product ; AP214/AP238 Step-NC/AP242   product_concept ; AP214/AP238 Step-NC/AP242   product_concept_feature ; AP214/AP238 Step-NC/AP242   product_concept_feature_association ; AP214/AP238 Step-NC/AP242   product_concept_feature_category ; AP214/AP238 Step-NC/AP242   product_concept_feature_category_usage ; AP214/AP238 Step-NC/AP242   product_definition ; AP214   product_definition_formation ; AP214/AP238 Step-NC/AP242   product_definition_formation_relationship ; AP214/AP238 Step-NC/AP242   product_definition_relationship ; AP214/AP238 Step-NC/AP242   product_definition_substitute ; AP214/AP238 Step-NC/AP242   property_definition ; AP214/AP238 Step-NC/AP242   requirement_for_action_resource ; AP214/AP242   resource_property ; AP214/AP242   security_classification ; AP214   security_classification_level ; AP214/AP238 Step-NC/AP242   shape_representation ; AP214/AP238 Step-NC/AP242   versioned_action_request ; AP214; EndEnumeration
  ; IN AP242
  ; Enumeration evidence_item ; = Select
      #action_property
      #action_property_representation
      #analysis_assignment
      #applied_action_assignment
      #applied_approval_assignment
      #applied_certification_assignment
      #applied_classification_assignment
      #applied_contract_assignment
      #applied_effectivity_assignment
      #applied_event_occurrence_assignment
      #applied_external_identification_assignment
      #applied_ineffectivity_assignment
      #applied_organizational_project_assignment
      #applied_organization_assignment
      #applied_person_and_organization_assignment
      #applied_security_classification_assignment
      #date_and_time_assignment
      #date_assignment
      #measure_representation_item
      #person
      #person_and_organization
      #product
      #product_definition
      #product_definition_context
      #product_definition_formation
      #product_definition_formation_relationship
      #product_definition_relationship
      #product_relationship
      #property_definition
      #property_definition_representation
      #representation
      #representation_context
      #representation_item
      #state_type
      #structured_message
      #validation
      #value_representation_item
      #verification
  ; EndEnumeration
      
  ; IN AP238 Step-NC
  ; Enumeration expression_element ; = Select
      #expression
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration expression_extension_select ; = Select
      #expression_extension_numeric
      #expression_extension_string
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration external_identification_item ; = Select   action_directive ; AP242   action_method ; AP242   action_method_relationship ; AP242   action_relationship ; AP203e2/AP238 Step-NC/AP242   action_request_status ; AP203e2/AP238 Step-NC/AP242   address ; AP242   analysis_model ; AP242   analysis_representation_context ; AP242   applied_action_method_assignment ; AP242   applied_classification_assignment ; AP242   applied_external_identification_assignment ; AP238 Step-NC/AP242   applied_organization_assignment ; AP203e2/AP238 Step-NC/AP242   applied_person_and_organization_assignment ; AP203e2/AP238 Step-NC/AP242   approval ; AP203e2/AP238 Step-NC/AP242   approval_person_organization ; AP242   approval_status ; AP203e2/AP238 Step-NC/AP242   assembly_bond_definition ; AP242   assembly_component_usage ; AP242   assembly_joint ; AP242   breakdown_context ; AP242   certification ; AP242   class ; AP242   composite_curve ; AP242   condition ; AP242   configuration_effectivity ; AP242   contract ; AP242   curve ; AP242   date_and_time_assignment ; AP203e2/AP238 Step-NC/AP242   date_assignment ; AP203e2/AP238 Step-NC/AP242   derived_unit ; AP242   document_file ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   effectivity ; AP242   evaluated_characteristic_of_product_as_individual_test_result ; AP242   event_occurrence ; AP242   evidence ; AP242   exclusive_product_concept_feature_category ; AP242   executed_action ; AP242   external_source ; AP203e2/AP238 Step-NC/AP242   externally_defined_class ; AP203e2/AP214/AP238 Step-NC/AP242   externally_defined_context_dependent_unit ; AP203e2/AP242   externally_defined_conversion_based_unit ; AP203e2/AP242   externally_defined_general_property ; AP203e2/AP214/AP224/AP238 Step-NC/AP242   externally_defined_item ; AP224   externally_defined_picture_representation_item ; AP203e2/AP242   externally_defined_representation_item ; AP203e2/AP238 Step-NC/AP242   general_property ; AP242   generic_product_definition_reference ; AP238 Step-NC/AP242   group ; AP242   information_right ; AP242   information_usage_right ; AP242   interface_connection ; AP242   interface_connector_definition ; AP242   interface_connector_occurrence ; AP242   interface_connector_version ; AP242   interface_definition_connection ; AP242   interface_definition_for ; AP242   interface_specification_definition ; AP242   interface_specification_version ; AP242   loop ; AP242   material_designation ; AP242   named_unit ; AP242   organization ; AP242   organizational_address ; AP203e2/AP238 Step-NC/AP242   organizational_project ; AP242   oriented_surface ; AP242   package_product_concept_feature ; AP242   person ; AP242   person_and_organization ; AP242   point_on_curve ; AP242   precision_qualifier ; AP242   process_operation ; AP242   process_plan ; AP242   product ; AP242   product_concept ; AP242   product_concept_context ; AP242   product_concept_feature ; AP242   product_concept_feature_category ; AP242   product_definition ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_definition_context ; AP242   product_definition_formation ; AP242   product_definition_occurrence ; AP242   product_definition_occurrence_reference ; AP242   product_group ; AP242   product_identification ; AP242   product_process_plan ; AP242   product_specification ; AP242   property_definition ; AP242   representation ; AP242   representation_item ; AP242   requirement_source ; AP242   satisfies_requirement ; AP242   security_classification ; AP203e2/AP238 Step-NC/AP242   shape_representation ; AP242   state_observed ; AP242   state_; Enumeration ; AP242   structured_message ; AP242   surface ; AP242   time_interval ; AP242   trimmed_curve ; AP203e2/AP238 Step-NC/AP242   ; Enumeration_qualifier ; AP242   uncertainty_qualifier ; AP242   validation ; AP242   verification ; AP242   versioned_action_request ; AP203e2/AP238 Step-NC/AP242   vertex_point ; AP242; EndEnumeration
  ; IN AP238 Step-NC/AP242
  ; Enumeration face_or_surface ; = Select
      #face
      #surface
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; Enumeration founded_item_select ; = Select
      #founded_item
      #representation_item
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration general_organizational_data_select ; = Select
      #action_directive
      #action_method
      #action_method_relationship
      #action_property
      #action_property_representation
      #action_relationship
      #action_request_solution
      #alternate_product_relationship
      #alternative_solution_relationship
      #applied_action_assignment
      #applied_action_method_assignment
      #applied_action_request_assignment
      #applied_approval_assignment
      #applied_certification_assignment
      #applied_classification_assignment
      #applied_contract_assignment
      #applied_description_text_assignment
      #applied_description_text_assignment_relationship
      #applied_document_reference
      #applied_document_usage_constraint_assignment
      #applied_effectivity_assignment
      #applied_event_occurrence_assignment
      #applied_external_identification_assignment
      #applied_identification_assignment
      #applied_ineffectivity_assignment
      #applied_organizational_project_assignment
      #applied_organization_assignment
      #applied_person_and_organization_assignment
      #applied_security_classification_assignment
      #applied_time_interval_assignment
      #applied_usage_right
      #approval
      #approval_person_organization
      #approval_relationship
      #approval_status
      #assembly_component_usage
      #assembly_component_usage_substitute
      #breakdown_element_group_assignment
      #breakdown_element_realization
      #breakdown_of
      #certification
      #characterized_product_concept_feature
      #characterized_product_concept_feature_category
      #class
      #class_system
      #condition
      #conditional_concept_feature
      #conditional_effectivity
      #configuration_design
      #configuration_effectivity
      #configuration_item
      #configured_effectivity_assignment
      #contract
      #date_and_time_assignment
      #date_assignment
      #directed_action_assignment
      #document_file
      #drawing_revision
      #drawing_sheet_revision
      #effectivity
      #evaluated_characteristic_of_product_as_individual_test_result
      #exclusive_product_concept_feature_category
      #executed_action
      #frozen_assignment
      #general_property
      #general_property_relationship
      #group
      #group_relationship
      #identification_assignment_relationship
      #inclusion_product_concept_feature
      #information_usage_right
      #material_designation
      #material_designation_characterization
      #measure_representation_item
      #organization
      #organizational_address
      #organizational_project
      #organization_relationship
      #package_product_concept_feature
      #person
      #person_and_organization
      #person_and_organization_address
      #presentation_area
      #process_operation
      #process_plan
      #product
      #product_class
      #product_concept
      #product_concept_feature
      #product_concept_feature_association
      #product_concept_feature_category
      #product_concept_feature_category_usage
      #product_definition
      #product_definition_formation
      #product_definition_formation_relationship
      #product_definition_group_assignment
      #product_definition_occurrence
      #product_definition_occurrence_reference
      #product_definition_relationship
      #product_definition_substitute
      #product_definition_usage
      #product_design_to_individual
      #product_design_version_to_individual
      #product_process_plan
      #product_relationship
      #property_definition
      #property_definition_representation
      #representation
      #representation_item
      #representation_relationship
      #requirement_assignment
      #requirement_for_action_resource
      #requirement_source
      #requirement_view_definition_relationship
      #security_classification
      #shape_representation
      #value_representation_item
      #versioned_action_request
  ; EndEnumeration
      
  ; DIFF IN AP203e2
  ; IN AP203e2/AP242
  ; Enumeration generalized_surface_select ; = Select
      #face_surface
      #surface
      #surfaced_open_shell
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration generic_property_definition_select ; = Select
      #action_property
      #dimensional_location
      #dimensional_size
      #property_definition
      #resource_property
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration geometric_constraint_element ; = Select
      #curve
      #direction
      #point
      #surface
      #vector
  ; EndEnumeration
      
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration geometric_item_specific_usage_select ; = Select
      #shape_aspect
      #shape_aspect_relationship
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration geometric_model_item ; = Select
      #connected_face_set
      #edge_loop
      #geometric_representation_item
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP224; DIFF IN AP232
  ; IN AP238 Step-NC/AP242
  ; Enumeration geometric_tolerance_target ; = Select
      #dimensional_location
      #dimensional_size
      #product_definition_shape
      #shape_aspect
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration gps_filtration_specification_target ; = Select
      #geometric_tolerance
  ; EndEnumeration
      
  ; IN AP238 Step-NC/AP242
  ; Enumeration gps_filtration_; Enumeration ; = Select
      #geometric_tolerance_modifier
  ; EndEnumeration
      
  ; DIFF IN AP224; IN AP214/AP224
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration groupable_item ; = Select
      #address
      #alternate_product_relationship
      #applied_action_assignment
      #applied_action_method_assignment
      #applied_action_request_assignment
      #applied_approval_assignment
      #applied_attribute_classification_assignment
      #applied_certification_assignment
      #applied_classification_assignment
      #applied_contract_assignment
      #applied_description_text_assignment
      #applied_document_reference
      #applied_document_usage_constraint_assignment
      #applied_effectivity_assignment
      #applied_event_occurrence_assignment
      #applied_external_identification_assignment
      #applied_group_assignment
      #applied_identification_assignment
      #applied_location_assignment
      #applied_location_representation_assignment
      #applied_name_assignment
      #applied_organization_assignment
      #applied_organization_type_assignment
      #applied_organizational_project_assignment
      #applied_person_and_organization_assignment
      #applied_security_classification_assignment
      #approval
      #approval_person_organization
      #approval_relationship
      #approval_status
      #ascribable_state
      #ascribable_state_relationship
      #assembly_component_usage
      #assembly_component_usage_substitute
      #attribute_language_assignment
      #breakdown_element_group_assignment
      #calendar_date
      #certification
      #component_feature
      #configuration_design
      #configuration_item
      #configuration_item_relationship
      #context_dependent_shape_representation
      #contract
      #contract_relationship
      #coordinated_universal_time_offset
      #date_and_time
      #date_and_time_assignment
      #date_assignment
      #derived_unit
      #derived_unit_element
      #description_text
      #document_file
      #document_relationship
      #effectivity
      #effectivity_relationship
      #event_occurrence
      #event_occurrence_relationship
      #evidence
      #external_source
      #general_property
      #general_property_relationship
      #geometric_item_specific_usage
      #geometric_representation_item
      #group_relationship
      #instanced_feature
      #interface_connector_definition
      #interface_definition_connection
      #interface_definition_for
      #item_defined_transformation
      #local_time
      #mapped_item
      #measure_qualification
      #measure_with_unit
      #multi_language_attribute_assignment
      #named_unit
      #organization
      #organization_relationship
      #organization_type
      #organizational_project
      #organizational_project_relationship
      #package_product_concept_feature
      #person
      #person_and_organization
      #precision_qualifier
      #product
      #product_concept
      #product_concept_context
      #product_concept_feature
      #product_definition
      #product_definition_context
      #product_definition_formation
      #product_definition_formation_relationship
      #product_definition_group_assignment
      #product_definition_relationship
      #product_group_membership
      #product_group_relationship
      #product_relationship
      #property_definition
      #property_definition_representation
      #replicate_feature
      #representation
      #representation_context
      #representation_item
      #representation_relationship
      #representation_relationship_with_transformation
      #security_classification
      #shape_aspect
      #shape_aspect_relationship
      #shape_representation_relationship
      #state_observed
      #state_observed_assignment
      #state_observed_relationship
      #state_observed_role
      #state_type
      #state_type_assignment
      #state_type_relationship
      #styled_item
      #time_interval
      #time_interval_assignment
      #time_interval_relationship
      #time_interval_role
      #topological_representation_item
      #transition_feature
      #type_qualifier
      #uncertainty_qualifier
      #verification_relationship
      #versioned_action_request
      ; WHERE  WR1: Not  'STEP_MERGED_AP_SCHEMA.GROUP' IN TypeOf SELF)
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration id_attribute_select ; = Select   action ; Common   address ; Common   application_context ; Common   ascribable_state_relationship ; AP242   dimensional_size ; AP238 Step-NC/AP242   geometric_tolerance ; AP238 Step-NC/AP242   group ; Common   organizational_project ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_category ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   property_definition ; Common   representation ; Common   shape_aspect ; Common   shape_aspect_relationship ; Common   topological_representation_item ; AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration identification_item ; = Select   action ; AP214/AP238 Step-NC/AP242   action_directive ; AP214/AP238 Step-NC/AP242   action_directive_relationship ; AP242   action_method ; AP214/AP238 Step-NC/AP242   action_method_relationship ; AP242   action_property ; AP214/AP238 Step-NC/AP242   action_property_representation ; AP242   action_relationship ; AP242   address ; AP242   alternate_product_relationship ; AP242   alternative_solution_relationship ; AP242   analysis_assignment ; AP242   analysis_representation_context ; AP242   application_context ; AP232   applied_action_assignment ; AP242   applied_action_method_assignment ; AP242   applied_action_request_assignment ; AP242   applied_approval_assignment ; AP242   applied_certification_assignment ; AP242   applied_classification_assignment_relationship ; AP242   applied_contract_assignment ; AP242   applied_description_text_assignment ; AP242   applied_description_text_assignment_relationship ; AP242   applied_document_reference ; AP232/AP242   applied_document_usage_constraint_assignment ; AP232/AP242   applied_effectivity_assignment ; AP242   applied_event_occurrence_assignment ; AP242   applied_external_identification_assignment ; AP242   applied_external_identification_assignment_relationship ; AP242   applied_identification_assignment ; AP214/AP238 Step-NC/AP242   applied_ineffectivity_assignment ; AP242   applied_organization_assignment ; AP242   applied_organizational_project_assignment ; AP242   applied_person_and_organization_assignment ; AP242   applied_security_classification_assignment ; AP242   applied_time_interval_assignment ; AP242   applied_usage_right ; AP242   approval ; AP242   approval_relationship ; AP242   approval_status ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   ascribable_state ; AP242   ascribable_state_relationship ; AP242   assembly_component_usage ; AP242   assembly_component_usage_substitute ; AP242   assignment_object_relationship ; AP242   breakdown_element_realization ; AP242   breakdown_of ; AP242   certification ; AP242   change_group ; AP242   characterized_class ; AP203e2/AP242   class ; AP203e2/AP214/AP238 Step-NC/AP242   class_system ; AP214/AP238 Step-NC/AP242   configuration_effectivity ; AP242   configuration_item ; AP203e2/AP214/AP238 Step-NC/AP242   configuration_item_relationship ; AP242   contract ; AP203e2/AP238 Step-NC/AP242   contract_relationship ; AP242   date_and_time_assignment ; AP242   date_assignment ; AP242   degenerate_pcurve ; AP242   dimensional_size ; AP203e2/AP214/AP238 Step-NC/AP242   dimensional_size_with_path ; AP242   directed_action_assignment ; AP242   document ; AP224   document_file ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   document_relationship ; AP242   document_; Enumeration ; AP214/AP238 Step-NC/AP242   draughting_model ; AP214/AP242   effectivity ; AP214/AP238 Step-NC/AP242   effectivity_relationship ; AP242   envelope ; AP242   envelope_relationship ; AP242   evaluated_characteristic ; AP242   event_occurrence ; AP242   event_occurrence_relationship ; AP242   evidence ; AP242   exclusive_product_concept_feature_category ; AP242   executed_action ; AP242   general_property ; AP203e2/AP214/AP242   general_property_relationship ; AP242   generic_property_relationship ; AP242   group ; AP203e2/AP238 Step-NC/AP242   group_relationship ; AP203e2/AP238 Step-NC/AP242   identification_assignment_relationship ; AP242   information_right ; AP203e2/AP238 Step-NC/AP242   information_usage_right ; AP203e2/AP238 Step-NC/AP242   interface_connection ; AP242   interface_connector_as_planned ; AP242   interface_connector_as_realized ; AP242   interface_connector_definition ; AP242   interface_connector_design ; AP242   interface_connector_occurrence ; AP242   interface_connector_version ; AP242   interface_definition_connection ; AP242   interface_definition_for ; AP242   interface_specification_definition ; AP242   interface_specification_version ; AP242   link_motion_relationship ; AP242   material_designation ; AP203e2/AP238 Step-NC/AP242   material_designation_characterization ; AP242   measure_representation_item ; AP214/AP238 Step-NC/AP242   mechanical_design_geometric_presentation_representation ; AP214/AP242   message_relationship ; AP242   organization ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   organization_relationship ; AP242   organizational_address ; AP242   organizational_project ; AP214/AP238 Step-NC/AP242   organizational_project_relationship ; AP242   package_product_concept_feature ; AP242   person ; AP242   person_and_organization ; AP203e2/AP214/AP238 Step-NC/AP242   person_and_organization_address ; AP242   point_on_surface ; AP242   presentation_area ; AP214/AP242   process_operation ; AP242   process_plan ; AP242   product ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_category ; AP203e2/AP238 Step-NC/AP242   product_class ; AP203e2/AP238 Step-NC/AP242   product_concept ; AP203e2/AP214/AP238 Step-NC/AP242   product_concept_context ; AP242   product_concept_feature ; AP203e2/AP214/AP238 Step-NC/AP242   product_concept_feature_category ; AP214/AP238 Step-NC/AP242   product_concept_relationship ; AP242   product_definition ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_definition_formation ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_definition_formation_relationship ; AP242   product_definition_occurrence ; AP242   product_definition_occurrence_reference ; AP242   product_definition_relationship ; AP214/AP238 Step-NC/AP242   product_definition_usage ; AP242   product_definition_usage_relationship ; AP242   product_group ; AP242   product_group_membership ; AP242   product_group_relationship ; AP242   product_identification ; AP203e2/AP238 Step-NC/AP242   product_process_plan ; AP242   product_relationship ; AP242   property_definition ; AP214/AP238 Step-NC/AP242   property_definition_relationship ; AP214/AP238 Step-NC/AP242   property_definition_representation ; AP242   representation ; AP203e2/AP238 Step-NC/AP242   representation_context ; AP242   representation_relationship ; AP242   requirement_assignment ; AP242   requirement_for_action_resource ; AP242   requirement_source ; AP242   retention ; AP242   rule_set ; AP203e2/AP242   satisfies_requirement ; AP242   security_classification ; AP203e2/AP238 Step-NC/AP242   security_classification_level ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   shape_aspect ; AP242   shape_aspect_relationship ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   shape_feature_definition ; AP242   shape_feature_definition_relationship ; AP242   shape_representation ; AP203e2/AP214/AP238 Step-NC/AP242   state_definition_to_state_assignment_relationship ; AP242   state_observed ; AP242   state_observed_assignment ; AP242   state_observed_relationship ; AP242   state_; Enumeration ; AP242   state_; Enumeration_assignment ; AP242   state_; Enumeration_relationship ; AP242   structured_message ; AP242   time_interval ; AP242   time_interval_relationship ; AP242   usage_association ; AP203e2/AP238 Step-NC/AP242   validation ; AP242   verification ; AP242   verification_relationship ; AP242   versioned_action_request ; AP214/AP238 Step-NC/AP242   versioned_action_request_relationship ; AP242; EndEnumeration
  ; IN AP238 Step-NC/AP242
  ; Enumeration idrm_marked_item ; = Select
      #document_file
      #product_definition
  ; EndEnumeration
      
  ; Enumeration inspected_ecdq_element_select = inspected_element_select;
  ;    WHERE
  ;       WR1: Not  'STEP_MERGED_AP_SCHEMA.B_SPLINE_OR_COMPOSITE_CURVE_SELECT' IN TypeOf SELF
  ;       wr2: Not  'STEP_MERGED_AP_SCHEMA.B_SPLINE_OR_RECTANGULAR_COMPOSITE_SURFACE_SELECT' IN TypeOf SELF
  ;       wr3: Not  'STEP_MERGED_AP_SCHEMA.CLOSED_OR_OPEN_SHELL_SELECT' IN TypeOf SELF
  ;       wr4: Not  'STEP_MERGED_AP_SCHEMA.CONNECTED_FACE_SET' IN TypeOf SELF
  ;       wr5: Not  'STEP_MERGED_AP_SCHEMA.CURVE' IN TypeOf SELF
  ;       wr6: Not  'STEP_MERGED_AP_SCHEMA.DIRECTION' IN TypeOf SELF
  ;       wr7: Not  'STEP_MERGED_AP_SCHEMA.EDGE_CURVE' IN TypeOf SELF
  ;       wr8: Not  'STEP_MERGED_AP_SCHEMA.EDGE_LOOP' IN TypeOf SELF
  ;       wr9: Not  'STEP_MERGED_AP_SCHEMA.FACE_SURFACE' IN TypeOf SELF
  ;       wr10: Not  'STEP_MERGED_AP_SCHEMA.MANIFOLD_SOLID_BREP' IN TypeOf SELF
  ;       wr11: Not  'STEP_MERGED_AP_SCHEMA.PLACEMENT' IN TypeOf SELF
  ;       wr12: Not  'STEP_MERGED_AP_SCHEMA.POINT' IN TypeOf SELF
  ;       wr13: Not  'STEP_MERGED_AP_SCHEMA.SURFACE' IN TypeOf SELF
  ;       wr14: Not  'STEP_MERGED_AP_SCHEMA.VERTEX_POINT' IN TypeOf SELF
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration inspected_element_select ; = Select
      #assembly_component_usage
      #axis2_placement_3d
      #b_spline_or_composite_curve_select
      #b_spline_or_rectangular_composite_surface_select
      #cartesian_transformation_operator_3d
      #closed_or_open_shell_select
      #connected_face_set
      #curve
      #direction
      #edge_curve
      #edge_loop
      #face_surface
      #global_uncertainty_assigned_context
      #global_unit_assigned_context
      #group
      #manifold_solid_brep
      #placement
      #point
      #presentation_layer_assignment
      #representation_item
      #styled_item
      #surface
      #vertex_point
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration inspected_equivalence_element_select ; = Select
      #connected_edge_set
      #connected_face_set
      #externally_defined_representation_item
      #manifold_solid_brep
      #point_cloud_dataset
      #product_definition_or_reference
      #shape_representation
      #shell_based_surface_model
      #shell_based_wireframe_model
      #vertex_point
  ; EndEnumeration
  
  ; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP238 Step-NC/AP242; Enumeration instance_usage_context_select ; = Select   process_product_association ; AP242   product_definition_group_assignment ; AP242   product_definition_relationship ; Common   product_definition_usage ; Common; EndEnumeration
  ; IN AP242
  ; Enumeration internal_or_reflected_shape_aspect ; = Select
      #identifier
      #shape_aspect
  ; EndEnumeration
  ; DIFF IN AP214; IN AP203e2/AP214/AP238 Step-NC/AP242; Enumeration invisibility_context ; = Select   draughting_model ; AP203e2/AP238 Step-NC/AP242   presentation_representation ; Common   presentation_set ; Common; EndEnumeration
  ; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration invisible_item ; = Select   draughting_callout ; AP203e2/AP214/AP238 Step-NC/AP242   presentation_layer_assignment ; AP203e2/AP214/AP238 Step-NC/AP242   representation ; Common   styled_item ; Common; EndEnumeration
  ; DIFF IN AP238 Step-NC; IN AP238 Step-NC/AP242; Enumeration item_identified_representation_usage_definition ; = Select   applied_action_assignment ; AP242   applied_action_method_assignment ; AP242   applied_action_request_assignment ; AP242   applied_approval_assignment ; AP242   applied_certification_assignment ; AP242   applied_classification_assignment ; AP242   applied_contract_assignment ; AP242   applied_date_and_time_assignment ; AP242   applied_date_assignment ; AP242   applied_document_reference ; AP242   applied_document_usage_constraint_assignment ; AP242   applied_effectivity_assignment ; AP242   applied_event_occurrence_assignment ; AP242   applied_external_identification_assignment ; AP242   applied_group_assignment ; AP242   applied_identification_assignment ; AP242   applied_ineffectivity_assignment ; AP242   applied_name_assignment ; AP242   applied_organization_assignment ; AP242   applied_organizational_project_assignment ; AP242   applied_person_and_organization_assignment ; AP242   applied_security_classification_assignment ; AP242   applied_time_interval_assignment ; AP242   applied_usage_right ; AP242   characterized_object ; Common   dimensional_size ; Common   geometric_tolerance ; Common   product_definition_relationship ; AP242   property_definition ; AP242   represented_definition ; Common; EndEnumeration
  ; DIFF IN AP238 Step-NC
      
  ; IN AP238 Step-NC/AP242
  ; Enumeration item_identified_representation_usage_select ; = Select
      #list_representation_item
      #representation_item
      #set_representation_item
  ; EndEnumeration
      
  ; DIFF IN AP214; IN AP214/AP238 Step-NC/AP242; Enumeration kinematic_analysis_definition ; = Select   interpolated_configuration_sequence ; Common   prescribed_path ; AP238 STEP-NC/AP242; EndEnumeration
  ; IN AP214
  ; Enumeration kinematic_frame_background ; = Select
      #point
      #curve
      #surface
  ; EndEnumeration
      
  ; IN AP238 Step-NC/AP242
  ; Enumeration kinematic_link_representation_items ; = Select
      #curve
      #point
      #rigid_placement
      #surface
  ; EndEnumeration
      
  ; IN AP214/AP238 Step-NC/AP242
  ; Enumeration kinematic_result ; = Select
      #interpolated_configuration_sequence
      #resulting_path
  ; EndEnumeration
  
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration kinematic_topology_representation_select ; = Select
      #kinematic_topology_directed_structure
      #kinematic_topology_network_structure
      #kinematic_topology_structure
  ; EndEnumeration
      
  ; IN AP214/AP232
  ; Enumeration language_item ; = Select
      #representation
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration length_or_plane_angle_measure_with_unit_select ; = Select
      #length_measure_with_unit
      #plane_angle_measure_with_unit
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration linear_geometry_constraint_element ; = Select
      #direction
      #line
      #plane
      #vector
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration link_or_shape_representation ; = Select
      #kinematic_link_representation
      #shape_representation
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration location_item ; = Select
      #assembly_component_usage
      #document_file
      #interface_connection
      #interface_connector_occurrence
      #interface_definition_connection
      #organization
      #organizational_project
      #organization_; Enumeration
      #person
      #person_and_organization
      #product
      #product_definition
      #product_definition_formation
      #product_definition_relationship
      #product_group
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration location_of_extreme_value_select ; = Select
      #boundary_curve_of_b_spline_or_rectangular_composite_surface
      #b_spline_curve_knot_locator
      #b_spline_curve_segment
      #b_spline_surface_knot_locator
      #b_spline_surface_patch
      #b_spline_surface_strip
      #composite_curve_transition_locator
      #face_bound
      #inspected_shape_element_select
      #oriented_edge
      #point_on_edge_curve
      #point_on_face_surface
      #rectangular_composite_surface_transition_locator
      #subedge
      #subface
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration location_representation_item ; = Select
      #organizational_address
      #person_and_organization_address
      #product
      #product_definition_formation
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration machining_feature_definition ; = Select
      #boss
      #compound_feature
      #externally_defined_feature_definition
      #flat_face
      #gear
      #marking
      #outer_round
      #outside_profile
      #pocket
      #protrusion
      #removal_volume
      #replicate_feature
      #revolved_profile
      #rib_top
      #round_hole
      #rounded_end
      #spherical_cap
      #Step
      #slot
      #thread
      #turned_knurl
  ; EndEnumeration
  
  ; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration marker_select ; = Select   marker_; Enumeration ; Common   pre_defined_marker ; AP203e2/AP214/AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration maths_atom ; = Select
      #maths_enum_atom
      #maths_simple_atom
  ; EndEnumeration
  
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration maths_enum_atom ; = Select
      #elementary_function_enumerators
      #elementary_space_enumerators
      #extension_options
      #lower_upper
      #open_closed
      #ordering_; Enumeration
      #repackage_options
      #space_constraint_; Enumeration
      #symmetry_; Enumeration
  
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration maths_expression ; = Select
      #atom_based_value
      #generic_expression
      #maths_tuple
  ; EndEnumeration
  
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration maths_function_select ; = Select
      #elementary_function_enumerators
      #maths_function
  ; EndEnumeration
  
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration maths_simple_atom ; = Select
      #maths_binary
      #maths_boolean
      #maths_integer
      #maths_logical
      #maths_number
      #maths_real
      #maths_string
  ; EndEnumeration
  
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration maths_space_or_function ; = Select
      #maths_function
      #maths_space
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration maths_value ; = Select
      #atom_based_value
      #maths_tuple
      #generic_expression
     ; WHERE constancy: Not 'GENERIC_EXPRESSION' IN stripped_TypeOf SELF() Or expression_is_constant SELF
  ; EndEnumeration
  
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration measure_value ; = Select   absorbed_dose_measure ; AP203e2/AP238 Step-NC/AP242   acceleration_measure ; AP203e2/AP238 Step-NC/AP242   amount_of_substance_measure ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   area_measure ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   capacitance_measure ; AP203e2/AP238 Step-NC/AP242   celsius_temperature_measure ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   conductance_measure ; AP203e2/AP238 Step-NC/AP242   context_dependent_measure ; Common   count_measure ; Common   descriptive_measure ; Common   dose_equivalent_measure ; AP203e2/AP238 Step-NC/AP242   electric_charge_measure ; AP203e2/AP238 Step-NC/AP242   electric_current_measure ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   electric_potential_measure ; AP203e2/AP238 Step-NC/AP242   energy_measure ; AP203e2/AP238 Step-NC/AP242   force_measure ; AP203e2/AP238 Step-NC/AP242   frequency_measure ; AP203e2/AP238 Step-NC/AP242   illuminance_measure ; AP203e2/AP238 Step-NC/AP242   inductance_measure ; AP203e2/AP238 Step-NC/AP242   length_measure ; Common   luminous_flux_measure ; AP203e2/AP238 Step-NC/AP242   luminous_intensity_measure ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   magnetic_flux_density_measure ; AP203e2/AP238 Step-NC/AP242   magnetic_flux_measure ; AP203e2/AP238 Step-NC/AP242   mass_measure ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   non_negative_length_measure ; AP203e2/AP214/AP238 Step-NC/AP242   numeric_measure ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   parameter_value ; Common   plane_angle_measure ; Common   positive_length_measure ; Common   positive_plane_angle_measure ; Common   positive_ratio_measure ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   power_measure ; AP203e2/AP238 Step-NC/AP242   pressure_measure ; AP203e2/AP238 Step-NC/AP242   radioactivity_measure ; AP203e2/AP238 Step-NC/AP242   ratio_measure ; Common   resistance_measure ; AP203e2/AP238 Step-NC/AP242   solid_angle_measure ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   thermodynamic_temperature_measure ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   time_measure ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   velocity_measure ; AP203e2/AP238 Step-NC/AP242   volume_measure ; AP203e2/AP214/AP232/AP238 STEP-NC/AP242; EndEnumeration
  ; IN AP242
  ; Enumeration measured_value_select ; = Select
      #boolean_value
      #measure_value
      #plane_angle_and_length_pair
      #plane_angle_and_ratio_pair
  ; EndEnumeration
  
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration mechanical_design_and_draughting_relationship_select ; = Select
      #draughting_model
      #mechanical_design_geometric_presentation_representation
      #mechanical_design_presentation_representation_with_draughting
      #mechanical_design_shaded_presentation_representation
      #shape_representation
  ; EndEnumeration
  
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration mechanical_design_geometric_presentation_area_items ; = Select
      #axis2_placement
      #mapped_item
  ; EndEnumeration
  
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration mechanical_design_geometric_presentation_representation_items ; = Select
      #axis2_placement
      #camera_model_d3
      #mapped_item
      #styled_item
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration mechanical_design_shaded_presentation_area_items ; = Select
      #axis2_placement
      #mapped_item
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration mechanical_design_shaded_presentation_representation_items ; = Select
      #axis2_placement
      #camera_model_d3
      #mapped_item
      #styled_item
  ; EndEnumeration
  
  ; IN AP214
  ; Enumeration motion_parameter_measure ; = Select
      #parameter_value
      #measure_w
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP214/AP238 Step-NC/AP242; Enumeration multi_language_attribute_item ; = Select   action ; AP214/AP238 Step-NC/AP242   action_directive ; AP214/AP238 Step-NC/AP242   action_directive_relationship ; AP242   action_method ; AP214/AP238 Step-NC/AP242   action_method_relationship ; AP242   action_property ; AP214/AP238 Step-NC/AP242   action_property_representation ; AP242   action_relationship ; AP214/AP238 Step-NC/AP242   actuated_kinematic_pair ; AP242   alternate_product_relationship ; AP203e2/AP214/AP242   alternative_solution_relationship ; AP242   analysis_assignment ; AP242   analysis_representation_context ; AP242   application_context ; AP203e2/AP214/AP242   applied_action_assignment ; AP242   applied_action_method_assignment ; AP242   applied_action_request_assignment ; AP242   applied_approval_assignment ; AP242   applied_certification_assignment ; AP203e2/AP242   applied_classification_assignment_relationship ; AP242   applied_contract_assignment ; AP242   applied_description_text_assignment ; AP242   applied_description_text_assignment_relationship ; AP242   applied_document_reference ; AP203e2/AP238 Step-NC/AP242   applied_document_usage_constraint_assignment ; AP203e2/AP238 Step-NC/AP242   applied_effectivity_assignment ; AP242   applied_event_occurrence_assignment ; AP242   applied_external_identification_assignment ; AP203e2/AP238 Step-NC/AP242   applied_external_identification_assignment_relationship ; AP242   applied_identification_assignment ; AP203e2/AP242   applied_ineffectivity_assignment ; AP242   applied_organization_assignment ; AP242   applied_organizational_project_assignment ; AP203e2/AP238 Step-NC/AP242   applied_person_and_organization_assignment ; AP242   applied_time_interval_assignment ; AP242   applied_usage_right ; AP242   approval ; AP203e2/AP238 Step-NC/AP242   approval_relationship ; Common   approval_status ; AP203e2/AP238 Step-NC/AP242   ascribable_state ; AP242   assembly_component_usage_substitute ; AP203e2/AP214/AP242   assignment_object_relationship ; AP242   attribute_value_assignment ; AP203e2/AP242   breakdown_context ; AP242   breakdown_element_realization ; AP242   breakdown_of ; AP242   certification ; Common   certification_; Enumeration ; AP203e2/AP238 Step-NC/AP242   change_element_sequence ; AP242   change_group ; AP242   class ; AP242   colour ; AP203e2/AP242   configuration_design ; AP203e2/AP214/AP242   configuration_effectivity ; AP242   configuration_item ; AP203e2/AP214/AP242   configuration_item_relationship ; AP242   contract ; Common   contract_relationship ; AP242   data_environment ; AP214/AP238 Step-NC/AP242   date_role ; Common   date_time_role ; Common   descriptive_representation_item ; AP203e2/AP214/AP242   directed_action_assignment ; AP242   document_file ; AP242   document_relationship ; Common   document_usage_role ; AP203e2/AP238 Step-NC/AP242   draughting_title ; AP214/AP242   effectivity ; AP203e2/AP214/AP242   effectivity_relationship ; AP203e2/AP214/AP242   envelope ; AP242   envelope_relationship ; AP242   evaluated_characteristic ; AP242   event_occurrence ; AP203e2/AP214/AP242   event_occurrence_relationship ; AP242   evidence ; AP242   exclusive_product_concept_feature_category ; AP242   executed_action ; AP242   external_source ; Common   externally_defined_class ; AP242   general_property ; AP203e2/AP214/AP242   general_property_relationship ; AP203e2/AP214/AP242   generic_property_relationship ; AP242   geometric_representation_item ; AP203e2/AP214/AP242   geometric_tolerance ; AP203e2/AP214/AP242   global_uncertainty_assigned_context ; AP242   global_unit_assigned_context ; AP242   group ; AP214/AP238 Step-NC/AP242   group_relationship ; AP214/AP238 Step-NC/AP242   identification_assignment_relationship ; AP242   identification_role ; Common   in_zone ; AP242   information_right ; AP203e2/AP238 Step-NC/AP242   information_usage_right ; AP203e2/AP238 Step-NC/AP242   interface_connection ; AP242   interface_connector_occurrence ; AP242   interface_definition_connection ; AP242   interface_definition_for ; AP242   kinematic_pair ; AP214/AP242   link_motion_relationship ; AP242   make_from_usage_option ; AP203e2/AP242   mapped_item ; AP203e2/AP214/AP242   material_designation_characterization ; AP242   measure_qualification ; AP242   measure_with_unit ; AP242   message_relationship ; AP242   name_assignment ; AP214/AP238 Step-NC/AP242   object_role ; AP203e2/AP238 Step-NC/AP242   organization ; AP242   organization_relationship ; Common   organization_role ; AP203e2/AP214/AP242   organizational_address ; AP242   organizational_project ; Common   organizational_project_relationship ; Common   organizational_project_role ; AP203e2/AP238 Step-NC/AP242   package_product_concept_feature ; AP242   pair_actuator ; AP214   person ; AP242   person_and_organization ; AP203e2/AP238 Step-NC/AP242   person_and_organization_address ; AP242   person_and_organization_role ; AP203e2/AP214/AP242   presentation_layer_assignment ; AP214/AP242   process_operation ; AP242   process_plan ; AP242   process_product_association ; AP214/AP242   product ; Common   product_concept ; AP203e2/AP214/AP242   product_concept_context ; AP242   product_concept_feature ; AP214/AP238 Step-NC/AP242   product_concept_feature_association ; AP214/AP238 Step-NC/AP242   product_concept_feature_category ; AP242   product_concept_feature_category_usage ; AP242   product_concept_relationship ; AP203e2/AP214/AP242   product_definition ; Common   product_definition_context ; AP203e2/AP242   product_definition_formation ; Common   product_definition_formation_relationship ; AP203e2/AP214/AP242   product_definition_relationship ; Common   product_definition_shape ; AP203e2/AP242   product_definition_substitute ; AP214/AP238 Step-NC/AP242   product_definition_usage ; AP242   product_definition_usage_relationship ; AP242   product_design_to_individual ; AP242   product_design_version_to_individual ; AP242   product_group ; AP242   product_group_relationship ; AP242   product_identification ; AP242   product_process_plan ; AP242   product_related_product_category ; AP203e2/AP214/AP242   product_relationship ; AP242   product_specification ; AP242   property_definition ; AP203e2/AP214/AP242   property_definition_relationship ; AP214/AP238 Step-NC/AP242   property_definition_representation ; AP242   qualitative_uncertainty ; AP242   representation ; AP203e2/AP214/AP242   representation_context ; AP242   representation_item ; AP242   representation_relationship ; AP203e2/AP214/AP242   representation_relationship_with_transformation ; AP242   requirement_assignment ; AP242   requirement_for_action_resource ; AP214/AP242   requirement_source ; AP242   resource_property ; AP214/AP242   resource_requirement_; Enumeration ; AP214/AP242   retention ; AP242   satisfies_requirement ; AP242   security_classification ; AP203e2/AP214/AP242   security_classification_assignment ; AP203e2/AP242   shape_aspect ; AP203e2/AP214/AP242   shape_aspect_relationship ; AP203e2/AP214/AP242   shape_feature_definition ; AP242   shape_feature_definition_relationship ; AP242   shape_representation ; AP203e2/AP242   state_definition_to_state_assignment_relationship ; AP242   state_observed ; AP242   state_observed_assignment ; AP242   state_observed_relationship ; AP242   state_; Enumeration ; AP242   state_; Enumeration_assignment ; AP242   state_; Enumeration_relationship ; AP242   structured_message ; AP242   styled_item ; AP214/AP242   time_interval ; AP242   time_interval_relationship ; AP242   time_interval_role ; AP203e2/AP214/AP242   topological_representation_item ; AP203e2/AP214/AP242   uncertainty_measure_with_unit ; AP203e2/AP214/AP242   uncertainty_qualifier ; AP214/AP238 Step-NC/AP242   usage_association ; AP203e2/AP238 Step-NC/AP242   validation ; AP242   verification ; AP242   verification_relationship ; AP242   versioned_action_request ; AP214/AP238 Step-NC/AP242   versioned_action_request_relationship ; AP214/AP242; EndEnumeration
  ; IN AP242
  ; Enumeration multi_or_next_assembly_usage_occurrence ; = Select
      #multi_level_reference_designator
      #next_assembly_usage_occurrence
  ; EndEnumeration
  
  ; DIFF IN AP224; Enumeration name_attribute_select ; = Select   action_request_solution ; Common   address ; Common   configuration_design ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   context_dependent_shape_representation ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   derived_unit ; Common   effectivity ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   person_and_organization ; Common   product_definition ; Common   product_definition_substitute ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   property_definition_representation ; Common; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP214/AP238 Step-NC/AP242; Enumeration name_item ; = Select   applied_action_assignment ; AP242   applied_action_method_assignment ; AP242   assembly_component_usage ; AP203e2/AP238 Step-NC/AP242   external_class_library ; AP203e2/AP238 Step-NC/AP242   group ; AP203e2/AP238 Step-NC/AP242   group_relationship ; AP203e2/AP238 Step-NC/AP242   kinematic_joint ; AP214   kinematic_link ; AP214   kinematic_structure ; AP214   product ; AP203e2/AP238 Step-NC/AP242   product_definition ; AP203e2/AP238 STEP-NC/AP242; EndEnumeration
  ; IN AP224
  ; Enumeration ordered_part_item ; = Select
      #product_definition_formation
  ; EndEnumeration
  
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP240; DIFF IN AP232; Enumeration organization_item ; = Select   ;fixture_assembly_element ; AP240   ;machine ; AP240   ;part_contract ; AP240   ;process_plan_activity ; AP240   ;tool_assembly_element ; AP240   action ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   action_directive ; AP203e2/AP214/AP224/AP238 Step-NC/AP242   action_method ; AP214/AP238 Step-NC/AP242   action_property ; AP214/AP238 Step-NC/AP242   action_relationship ; AP214/AP238 Step-NC/AP242   action_request_solution ; AP214/AP238 Step-NC/AP242   alternate_product_relationship ; AP203e2/AP214/AP242   applied_action_assignment ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   applied_action_method_assignment ; AP242   applied_certification_assignment ; AP242   applied_classification_assignment ; AP203e2/AP214/AP238 Step-NC/AP242   applied_contract_assignment ; AP232/AP242   applied_document_reference ; AP242   applied_document_usage_constraint_assignment ; AP242   applied_effectivity_assignment ; AP242   applied_event_occurrence_assignment ; AP242   applied_identification_assignment ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   applied_organization_assignment ; AP214/AP238 Step-NC/AP242   applied_organizational_project_assignment ; AP242   applied_person_and_organization_assignment ; AP214/AP238 Step-NC/AP242   applied_security_classification_assignment ; AP203e2/AP238 Step-NC/AP242   approval ; AP203e2/AP214/AP238 Step-NC/AP242   approval_status ; AP214/AP238 Step-NC/AP242   ascribable_state ; AP242   assembly_component_usage_substitute ; AP203e2/AP214/AP242   certification ; AP203e2/AP214/AP242   class ; AP203e2/AP214/AP238 Step-NC/AP242   class_system ; AP214/AP238 Step-NC/AP242   configuration_design ; AP214/AP238 Step-NC/AP242   configuration_effectivity ; AP214/AP238 Step-NC/AP242   configuration_item ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   configured_effectivity_assignment ; AP214/AP238 Step-NC/AP242   contract ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   data_equivalence_definition ; AP242   data_quality_definition ; AP242   date_and_time_assignment ; AP242   date_assignment ; AP242   document_file ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   document_; Enumeration ; AP214/AP238 Step-NC/AP242   draughting_model ; AP214/AP242   drawing_revision ; AP214/AP242   effectivity ; AP214/AP238 Step-NC/AP242   envelope ; AP242   event_occurrence ; AP214/AP232/AP238 Step-NC/AP242   evidence ; AP242   executed_action ; AP203e2/AP214/AP238 Step-NC/AP242   externally_defined_item ; AP224   general_property ; AP203e2/AP214/AP242   general_property_relationship ; AP242   information_right ; AP242   information_usage_right ; AP203e2/AP238 Step-NC/AP242   interface_connection ; AP242   interface_connector_as_planned ; AP242   interface_connector_as_realized ; AP242   interface_connector_occurrence ; AP242   interface_definition_connection ; AP242   interface_definition_for ; AP242   known_source ; AP224/AP240   material_designation ; AP214/AP238 Step-NC/AP242   mechanical_design_geometric_presentation_representation ; AP214/AP242   organization ; AP214/AP238 Step-NC/AP242   organization_relationship ; AP214/AP238 Step-NC/AP242   organizational_address ; AP242   organizational_project ; AP203e2/AP214/AP232/AP242   person_and_organization ; AP214/AP238 Step-NC/AP242   presentation_area ; AP214/AP242   product ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_concept ; AP214/AP238 Step-NC/AP242   product_concept_feature ; AP214/AP238 Step-NC/AP242   product_concept_feature_association ; AP214/AP238 Step-NC/AP242   product_concept_feature_category ; AP214/AP238 Step-NC/AP242   product_concept_feature_category_usage ; AP214/AP238 Step-NC/AP242   product_definition ; AP203e2/AP214/AP232/AP238 Step-NC/AP240/AP242   product_definition_context ; AP242   product_definition_formation ; AP203e2/AP214/AP224/AP232/AP238 Step-NC/AP242   product_definition_formation_relationship ; AP203e2/AP214/AP238 Step-NC/AP242   product_definition_relationship ; AP214/AP238 Step-NC/AP242   product_definition_substitute ; AP214/AP238 Step-NC/AP242   product_group ; AP242   product_group_membership ; AP242   product_group_relationship ; AP242   property_definition ; AP203e2/AP214/AP242   property_definition_representation ; AP242   representation ; AP242   requirement_assignment ; AP242   requirement_for_action_resource ; AP214/AP242   requirement_source ; AP242   resource_property ; AP214/AP242   rule_action ; AP203e2/AP242   satisfies_requirement ; AP242   security_classification ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   security_classification_level ; AP214/AP238 Step-NC/AP242   shape_representation ; AP203e2/AP214/AP242   state_observed ; AP242   state_observed_assignment ; AP242   state_observed_relationship ; AP242   state_; Enumeration ; AP242   state_; Enumeration_assignment ; AP242   state_; Enumeration_relationship ; AP242   structured_message ; AP242   validation ; AP242   verification ; AP242   versioned_action_request ; AP203e2/AP214/AP232/AP238 STEP-NC/AP242; EndEnumeration
  ; IN AP242
  ; Enumeration organization_; Enumeration_item ; = Select
      #organization
  ; EndEnumeration
  
  ; IN AP203e2/AP242
  ; Enumeration orientation_basis_select ; = Select
      #axis2_placement_3d
      #min_and_major_ply_orientation_basis
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration path_or_composite_curve ; = Select
      #composite_curve
      #path
  ; EndEnumeration
  
  ; Enumeration pcurve_or_surface ; = Select
      #pcurve
      #surface
  ; EndEnumeration
  
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN Deprecated AP203e1; DIFF IN AP232; Enumeration person_and_organization_item ; = Select   action ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   action_directive ; AP203e2/AP214/AP224/AP238 Step-NC/AP242   action_method ; AP214/AP238 Step-NC/AP242   action_property ; AP214/AP238 Step-NC/AP242   action_relationship ; AP214/AP238 Step-NC/AP242   action_request_solution ; AP214/AP238 Step-NC/AP242   alternate_product_relationship ; AP203e2/AP214/AP242   applied_action_assignment ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   applied_action_method_assignment ; AP242   applied_certification_assignment ; AP242   applied_classification_assignment ; AP203e2/AP214/AP238 Step-NC/AP242   applied_contract_assignment ; AP232/AP242   applied_document_reference ; AP242   applied_document_usage_constraint_assignment ; AP242   applied_effectivity_assignment ; AP242   applied_event_occurrence_assignment ; AP242   applied_identification_assignment ; AP203e2/AP232/AP238 Step-NC/AP242   applied_organization_assignment ; AP214/AP238 Step-NC/AP242   applied_organizational_project_assignment ; AP242   applied_person_and_organization_assignment ; AP214/AP238 Step-NC/AP242   applied_security_classification_assignment ; AP203e2/AP238 Step-NC/AP242   approval ; AP203e2/AP238 Step-NC/AP242   approval_status ; AP214/AP238 Step-NC/AP242   ascribable_state ; AP242   assembly_component_usage_substitute ; AP203e2/AP214/AP242   certification ; AP203e2/AP214/AP242   change ; Deprecated AP203e1   change_request ; Deprecated AP203e1   class ; AP214/AP238 Step-NC/AP242   class_system ; AP214/AP238 Step-NC/AP242   configuration_design ; AP214/AP238 Step-NC/AP242   configuration_effectivity ; AP214/AP238 Step-NC/AP242   configuration_item ; AP203e2/AP214/AP232/AP238 Step-NC/AP242/Deprecated AP203e1   configured_effectivity_assignment ; AP214/AP238 Step-NC/AP242   contract ; AP203e2/AP214/AP232/AP238 Step-NC/AP242/Deprecated AP203e1   data_equivalence_definition ; AP242   data_quality_definition ; AP242   date_and_time_assignment ; AP242   date_assignment ; AP242   document_file ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   document_; Enumeration ; AP214/AP238 Step-NC/AP242   draughting_model ; AP214/AP242   drawing_revision ; AP214/AP242   effectivity ; AP242   envelope ; AP242   event_occurrence ; AP214/AP232/AP238 Step-NC/AP242   evidence ; AP242   executed_action ; AP203e2/AP214/AP238 Step-NC/AP242   general_property ; AP203e2/AP214/AP242   general_property_relationship ; AP242   information_usage_right ; AP203e2/AP238 Step-NC/AP242   interface_connection ; AP242   interface_connector_as_planned ; AP242   interface_connector_as_realized ; AP242   interface_connector_occurrence ; AP242   interface_definition_connection ; AP242   interface_definition_for ; AP242   material_designation ; AP214/AP238 Step-NC/AP242   mechanical_design_geometric_presentation_representation ; AP214/AP242   organization ; AP214/AP238 Step-NC/AP242   organization_relationship ; AP214/AP238 Step-NC/AP242   organizational_address ; AP242   organizational_project ; AP203e2/AP214/AP232/AP242   person_and_organization ; AP203e2/AP214/AP238 Step-NC/AP242   presentation_area ; AP214/AP242   product ; AP203e2/AP214/AP232/AP238 Step-NC/AP242/Deprecated AP203e1   product_concept ; AP214/AP238 Step-NC/AP242   product_concept_feature ; AP214/AP238 Step-NC/AP242   product_concept_feature_association ; AP214/AP238 Step-NC/AP242   product_concept_feature_category ; AP214/AP238 Step-NC/AP242   product_concept_feature_category_usage ; AP214/AP238 Step-NC/AP242   product_definition ; AP203e2/AP214/AP232/AP238 Step-NC/AP242/Deprecated AP203e1   product_definition_context ; AP242   product_definition_formation ; Common   product_definition_formation_relationship ; AP203e2/AP214/AP238 Step-NC/AP242   product_definition_relationship ; AP214/AP238 Step-NC/AP242   product_definition_substitute ; AP214/AP238 Step-NC/AP242   product_group ; AP242   product_group_membership ; AP242   product_group_relationship ; AP242   property_definition ; AP203e2/AP214/AP242   property_definition_representation ; AP242   representation ; AP242   requirement_assignment ; AP242   requirement_for_action_resource ; AP214/AP242   requirement_source ; AP242   resource_property ; AP214/AP242   rule_action ; AP203e2/AP242   security_classification ; AP203e2/AP214/AP232/AP238 Step-NC/AP242/Deprecated AP203e1   security_classification_level ; AP214/AP238 Step-NC/AP242   shape_representation ; AP203e2/AP214/AP242   start_request ; Deprecated AP203e1   start_work ; Deprecated AP203e1   state_observed ; AP242   state_observed_assignment ; AP242   state_observed_relationship ; AP242   state_; Enumeration ; AP242   state_; Enumeration_assignment ; AP242   state_; Enumeration_relationship ; AP242   structured_message ; AP242   validation ; AP242   verification ; AP242   versioned_action_request ; AP203e2/AP214/AP232/AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; DIFF IN AP224
  ; DIFF IN AP232
  ; Enumeration person_organization_select ; = Select
      #organization
      #person
      #person_and_organization
  ; EndEnumeration
  
  ; DIFF IN AP203e2
  ; IN AP203e2/AP242
  ; Enumeration picture_representation_item_select ; = Select
      #axis2_placement_2d
      #planar_box
      #styled_item
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration planar_curve_select ; = Select
      #line
      #conic
      #trimmed_curve
      #pcurve
      #surface_curve
  ;    WHERE
  ;       wr1: SELF\geometric_representation_item.Dim = 3;
  ;       wr2: check_curve_planarity SELF
  ; EndEnumeration
  
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; Enumeration plane_or_planar_box ; = Select
      #planar_box
      #plane
  ; EndEnumeration
  
  ; DIFF IN AP203e2
  ; IN AP203e2/AP242
  ; Enumeration point_and_vector_member ; = Select
      #direction
      #point
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration point_cloud_set_or_superset ; = Select
      #point_cloud_dataset
      #point_cloud_superdataset
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration point_curve_or_surface_constraint_element ; = Select
      #curve
      #point
      #surface
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration point_placement_shape_representation_item ; = Select
      #axis2_placement_3d
      #compound_representation_item
      #mapped_item
  ; EndEnumeration
  
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; Enumeration presentation_representation_select ; = Select
      #presentation_representation
      #presentation_set
  ; EndEnumeration
  
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; DIFF IN AP232
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; Enumeration presentation_size_assignment_select ; = Select
      #area_in_set
      #presentation_area
      #presentation_view
  ; EndEnumeration
  
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration presentation_style_select ; = Select   approximation_tolerance ; AP214   curve_style ; Common   externally_defined_style ; AP214/AP232/AP238 Step-NC/AP242   fill_area_style ; Common   null_style ; AP203e2/AP214/AP238 Step-NC/AP242   point_style ; Common   pre_defined_presentation_style ; AP214   surface_style_usage ; Common   symbol_style ; AP203e2/AP214/AP238 Step-NC/AP242   text_style ; Common   texture_style_tessellation_specification ; AP242; EndEnumeration
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; Enumeration presented_item_select ; = Select
      #action
      #action_method
      #action_relationship
      #product_concept
      #product_concept_feature
      #product_concept_feature_category
      #product_definition
      #product_definition_formation
      #product_definition_relationship
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration previous_element_assignment_select ; = Select
      #delete_element
      #modify_element
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration product_definition_occurrence_or_reference ; = Select
      #product_definition_occurrence
      #product_definition_occurrence_reference
  ; EndEnumeration
  
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration product_definition_or_assembly_relationship ; = Select
      #assembly_component_usage
      #product_definition
  ; EndEnumeration
  
  ; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP238 Step-NC/AP242; Enumeration product_definition_or_breakdown_element_usage ; = Select   product ; AP242   product_definition ; Common   product_definition_formation ; AP242   product_definition_usage ; Common; EndEnumeration
  ; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP238 Step-NC/AP242; Enumeration product_definition_or_product_definition_relationship ; = Select   interface_connector_occurrence ; AP242   product ; AP242   product_definition ; Common   product_definition_usage ; Common   product_group ; AP242; EndEnumeration
  ; IN AP238 Step-NC/AP242
  ; Enumeration product_definition_or_reference ; = Select
      #generic_product_definition_reference
      #product_definition
      #product_definition_occurrence
  ; EndEnumeration
  
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; DIFF IN AP224
  ; DIFF IN AP232
  ; Enumeration product_or_formation_or_definition ; = Select
      #product
      #product_definition
      #product_definition_formation
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration product_select ; = Select
      #product
      #product_concept
      #product_definition_formation
      #product_group
  ; EndEnumeration
  
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration product_space ; = Select
      #listed_product_space
      #uniform_product_space
  ; EndEnumeration
  
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration project_item ; = Select   action ; AP232   action_method ; AP242   action_method_relationship ; AP242   applied_action_assignment ; AP242   applied_action_method_assignment ; AP242   assembly_component_usage ; AP214/AP238 Step-NC/AP242   configuration_item ; AP214/AP238 Step-NC/AP242   executed_action ; AP203e2/AP214/AP238 Step-NC/AP242   measure_representation_item ; AP242   product ; AP214/AP238 Step-NC/AP242   product_concept ; Common   product_definition ; AP214/AP238 Step-NC/AP242   product_definition_formation ; AP214/AP238 Step-NC/AP242   product_definition_occurrence ; AP242   product_definition_occurrence_reference ; AP242   product_group ; AP242   product_group_membership ; AP242   product_group_relationship ; AP242   product_identification ; AP242   property_definition_representation ; AP242   representation ; AP242   representation_item ; AP242   value_representation_item ; AP242; EndEnumeration
  ; IN AP214/AP238 Step-NC/AP242
  ; Enumeration property_or_shape_select ; = Select
      #property_definition
      #shape_definition
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration property_variable_rep_select ; = Select
      #dimensional_size
      #representation
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration radial_geometry_constraint_element ; = Select
      #circle
      #conical_surface
      #cylindrical_surface
      #right_circular_cone
      #right_circular_cylinder
      #sphere
      #spherical_surface
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration real_interval ; = Select
      #real_interval_from_min
      #real_interval_to_max
      #finite_real_interval
      #elementary_space
     ;WHERE 
     ;    WR1: Not  'ELEMENTARY_SPACE' IN stripped_ TypeOf SELF() Or  SELF\elementary_space.space_id = es_reals
  ; EndEnumeration
  
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; Enumeration rendering_properties_select ; = Select
      #surface_style_reflectance_ambient
      #surface_style_transparent
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration representation_or_representation_reference ; = Select
      #representation
      #representation_reference
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration representation_proxy_select ; = Select
      #product_definition_formation
  ; EndEnumeration
  
  ; Enumeration represented_definition ; = Select
      #general_property
      #property_definition
      #property_definition_relationship
      #shape_aspect
      #shape_aspect_relationship
  ; EndEnumeration
  
  ; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP238 Step-NC/AP242; Enumeration requirement_assigned_item ; = Select   action_method ; AP242   alternate_product_relationship ; AP242   applied_action_method_assignment ; AP242   applied_state_observed_assignment ; AP242   applied_state_; Enumeration_assignment ; AP242   assembly_component_usage ; AP242   assembly_component_usage_substitute ; AP242   characterized_object ; AP238 Step-NC/AP242   configuration_item ; Common   descriptive_representation_item ; Common   dimensional_location ; AP238 Step-NC/AP242   dimensional_size ; AP238 Step-NC/AP242   geometric_tolerance ; AP238 Step-NC/AP242   interface_connector_occurrence ; AP242   organizational_project ; AP242   product ; Common   product_class ; Common   product_definition ; Common   product_definition_formation ; Common   product_definition_group_assignment ; AP242   product_definition_relationship ; Common   product_group ; AP242   product_group_membership ; AP242   quantified_assembly_component_usage ; AP242   representation ; Common   shape_aspect ; Common   state_observed ; AP242   state_; Enumeration ; AP242   validation ; AP242   verification ; AP242   versioned_action_request ; AP242; EndEnumeration
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration requirement_satisfaction_item ; = Select
      #requirement_assigned_item
  ; EndEnumeration
  
  ; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP238 Step-NC/AP242; Enumeration requirement_source_item ; = Select   action_method ; AP242   applied_action_method_assignment ; AP242   applied_state_observed_assignment ; AP242   applied_state_; Enumeration_assignment ; AP242   characterized_object ; Common   contract ; AP242   dimensional_location ; AP238 Step-NC/AP242   dimensional_size ; AP238 Step-NC/AP242   executed_action ; AP242   geometric_tolerance ; AP238 Step-NC/AP242   group ; Common   group_relationship ; Common   interface_connector_occurrence ; AP242   organization ; AP242   organizational_project ; AP242   person_and_organization ; AP242   product ; Common   product_definition ; Common   product_definition_formation ; Common   product_definition_relationship ; Common   shape_aspect ; Common   state_observed ; AP242   state_; Enumeration ; AP242   validation ; AP242   verification ; AP242; EndEnumeration
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; DIFF IN AP224
  ; DIFF IN AP232
  ; Enumeration reversible_topology ; = Select
      #list_of_reversible_topology_item
      #reversible_topology_item
      #set_of_reversible_topology_item
  ; EndEnumeration
      
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; DIFF IN AP224
  ; DIFF IN AP232
  ; Enumeration reversible_topology_item ; = Select
      #closed_shell
      #edge
      #face
      #face_bound
      #open_shell
      #path
  ; EndEnumeration
  
  ; DIFF IN AP214; IN AP214/AP238 Step-NC/AP242; Enumeration rigid_placement ; = Select   axis2_placement_3d ; Common   su_parameters ; AP238 STEP-NC/AP242;
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP224; DIFF IN AP232; Enumeration role_select ; = Select   action_assignment ; Common   action_request_assignment ; Common   approval_assignment ; Common   approval_date_time ; Common   certification_assignment ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   contract_assignment ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   directed_action_assignment ; AP238 Step-NC/AP242   document_reference ; Common   effectivity_assignment ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   group_assignment ; AP203e2/AP214/AP224/AP238 Step-NC/AP242   name_assignment ; AP203e2/AP214/AP238 Step-NC/AP242   security_classification_assignment ; Common; EndEnumeration
  ; IN AP214
  ; Enumeration rotational_range_measure ; = Select
      #plane_angle_measure
      #unlimited_range
  ; EndEnumeration
      
  ; IN AP203e2/AP242
  ; Enumeration rule_superseded_item ; = Select
      #product_definition_formation
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration same_as_item ; = Select
      #address
      #applied_external_identification_assignment
      #approval
      #approval_status
      #attribute_language_assignment
      #calendar_date
      #certification
      #contract
      #coordinated_universal_time_offset
      #date_and_time
      #derived_unit
      #derived_unit_element
      #event_occurrence
      #external_source
      #general_property
      #information_right
      #information_usage_right
      #language
      #local_time
      #measure_with_unit
      #named_unit
      #organization
      #person
      #product_definition_context
      #representation_context
      #requirement_source
      #security_classification
      #time_interval
      #usage_association
  ; EndEnumeration
  
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN Deprecated AP203e1; DIFF IN AP232; Enumeration security_classification_item ; = Select   action ; AP214/AP238 Step-NC/AP242   action_directive ; AP214/AP238 Step-NC/AP242   action_method ; AP242   action_method_relationship ; AP242   action_property ; AP214/AP238 Step-NC/AP242   action_property_representation ; AP242   applied_action_assignment ; AP214/AP238 Step-NC/AP242   applied_action_method_assignment ; AP242   applied_classification_assignment ; AP242   applied_description_text_assignment ; AP242   applied_description_text_assignment_relationship ; AP242   applied_document_reference ; AP242   applied_document_usage_constraint_assignment ; AP242   applied_external_identification_assignment ; AP242   applied_identification_assignment ; AP242   assembly_component_usage ; AP203e2/AP238 Step-NC/AP242/Deprecated AP203e1   assembly_component_usage_substitute ; AP214/AP238 Step-NC/AP242   class_system ; AP214/AP238 Step-NC/AP242   conditional_effectivity ; AP242   configuration_design ; AP214/AP238 Step-NC/AP242   configuration_effectivity ; AP214/AP238 Step-NC/AP242   configured_effectivity_assignment ; AP214/AP238 Step-NC/AP242   document ; AP203e2/AP238 Step-NC/AP242   document_file ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   draughting_model ; AP214/AP242   drawing_revision ; AP214/AP242   envelope ; AP242   evaluated_characteristic_of_product_as_individual_test_result ; AP242   evidence ; AP242   exclusive_product_concept_feature_category ; AP242   executed_action ; AP214/AP238 Step-NC/AP242   externally_defined_general_property ; AP242   general_property ; AP214/AP238 Step-NC/AP242   group ; AP242   identification_assignment_relationship ; AP242   interface_connection ; AP242   interface_connector_as_planned ; AP242   interface_connector_as_realized ; AP242   interface_connector_design ; AP242   interface_connector_occurrence ; AP242   interface_definition_connection ; AP242   interface_definition_for ; AP242   machining_operation ; AP238 Step-NC   machining_process_executable ; AP238 Step-NC   machining_toolpath ; AP238 Step-NC   make_from_usage_option ; AP203e2/AP238 Step-NC/AP242   material_designation ; AP214/AP238 Step-NC/AP242   mechanical_design_geometric_presentation_representation ; AP214/AP242   organizational_project ; AP214/AP238 Step-NC/AP242   package_product_concept_feature ; AP242   presentation_area ; AP214/AP242   process_plan ; AP242   product ; AP203e2/AP214/AP238 Step-NC/AP242   product_class ; AP242   product_concept ; AP214/AP238 Step-NC/AP242   product_concept_feature ; AP214/AP238 Step-NC/AP242   product_concept_feature_category ; AP214/AP238 Step-NC/AP242   product_definition ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   product_definition_formation ; Common   product_definition_formation_relationship ; AP242   product_definition_group_assignment ; AP242   product_definition_relationship ; AP214/AP232/AP238 Step-NC/AP242   product_definition_usage ; AP203e2/AP242   product_design_to_individual ; AP242   product_design_version_to_individual ; AP242   product_group ; AP242   product_group_membership ; AP242   product_group_relationship ; AP242   product_identification ; AP242   product_process_plan ; AP242   product_relationship ; AP242   property_definition ; AP214/AP232/AP238 Step-NC/AP242   property_definition_representation ; AP242   representation ; AP242   requirement_assignment ; AP242   requirement_source ; AP242   requirement_view_definition_relationship ; AP242   resource_property ; AP214/AP242   shape_representation ; AP214/AP238 Step-NC/AP242   structured_message ; AP242   validation ; AP242   verification ; AP242   versioned_action_request ; AP214/AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration shape_aspect_or_characterized_object ; = Select
      #characterized_object
      #shape_aspect
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration shape_data_quality_assessment_specification_select ; = Select
      #shape_data_quality_assessment_by_logical_test
      #shape_data_quality_assessment_by_numerical_test
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration shape_data_quality_value_limit_; Enumeration_select ; = Select
      #shape_data_quality_value_limit
      #shape_data_quality_value_range
  ; EndEnumeration
  
  ; Enumeration shape_definition ; = Select
      #product_definition_shape
      #shape_aspect
      #shape_aspect_relationship
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration shape_dimension_representation_item ; = Select
      #compound_representation_item
      #descriptive_representation_item
      #measure_representation_item
      #placement
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration shape_model ; = Select
      #constructive_geometry_representation
      #shape_representation
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration shape_representation_item ; = Select
      #geometric_representation_item
      #topological_representation_item
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration shape_representation_with_parameters_items ; = Select
      #descriptive_representation_item
      #direction
      #measure_representation_item
      #placement
  ; EndEnumeration
  
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration shell ; = Select   closed_shell ; Common   open_shell ; Common   vertex_shell ; AP203e2/AP232/AP238 Step-NC/AP242   wire_shell ; AP203e2/AP232/AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; DIFF IN AP232
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; Enumeration size_select ; = Select
      #descriptive_measure
      #measure_with_unit
      #positive_length_measure
  ; EndEnumeration
  
  ; DIFF IN AP203e2; IN AP203e2/AP242; Enumeration sketch_basis_select ; = Select   curve_bounded_surface ; Common   face_surface ; Common   planar_curve_select ; AP242; EndEnumeration
  ; IN AP242
  ; Enumeration sketch_element_select ; = Select
      #curve
      #point
     ; WHERE
     ;   WR1: 'STEP_MERGED_AP_SCHEMA.GEOMETRIC_REPRESENTATION_ITEM' IN  TypeOf SELF
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration sketch_; Enumeration_select ; = Select
      #neutral_sketch_representation
      #positioned_sketch
      #subsketch
  ; EndEnumeration
  
  ; DIFF IN AP214; DIFF IN AP224; Enumeration source_item ; = Select   identifier ; Common   message ; AP203e2/AP232/AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP214
  ; DIFF IN AP238 Step-NC
  ; IN AP214/AP238 Step-NC/AP242
  ; Enumeration spatial_rotation ; = Select
      #rotation_about_direction
      #ypr_rotation
  ; EndEnumeration
  
  ; IN AP214/AP242
  ; Enumeration specified_item ; = Select
      #drawing_revision
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration spherical_pair_select ; = Select
      #spherical_pair
      #spherical_pair_with_pin
  ; EndEnumeration
  
  ; IN AP203e2/AP242
  ; Enumeration start_request_item ; = Select
      #product_definition_formation
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration state_observed_of_item ; = Select
      #alternate_product_relationship
      #applied_action_method_assignment
      #applied_external_identification_assignment
      #approval
      #assembly_component_usage
      #assembly_component_usage_substitute
      #attachment_slot_design_to_planned
      #attachment_slot_design_to_realized
      #attachment_slot_on_product
      #attachment_slot_planned_to_realized
      #breakdown_element_group_assignment
      #breakdown_element_usage
      #certification
      #configuration_item
      #contract
      #document_file
      #Evidence
      #final_solution
      #group
      #interface_connection
      #interface_connector_as_planned
      #interface_connector_as_realized
      #interface_connector_definition
      #interface_connector_design
      #interface_connector_occurrence
      #interface_connector_version
      #interface_definition_connection
      #interface_specification_definition
      #interface_specification_version
      #organization
      #organizational_project
      #person_and_organization
      #product
      #product_category
      #product_concept
      #product_definition
      #product_definition_formation
      #product_definition_group_assignment
      #product_definition_relationship
      #product_in_attachment_slot
      #security_classification
      #structured_message
      #validation
      #verification
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration state_; Enumeration_of_item ; = Select
      #action_method
      #alternate_product_relationship
      #applied_action_method_assignment
      #applied_external_identification_assignment
      #approval
      #assembly_component_usage
      #assembly_component_usage_substitute
      #attachment_slot_design_to_planned
      #attachment_slot_design_to_realized
      #attachment_slot_on_product
      #attachment_slot_planned_to_realized
      #breakdown_element_group_assignment
      #breakdown_element_usage
      #certification
      #configuration_item
      #contract
      #document_file
      #evidence
      #final_solution
      #interface_connection
      #interface_connector_as_planned
      #interface_connector_as_realized
      #interface_connector_definition
      #interface_connector_design
      #interface_connector_occurrence
      #interface_connector_version
      #interface_definition_connection
      #interface_specification_definition
      #interface_specification_version
      #organization
      #organizational_project
      #person_and_organization
      #product
      #product_category
      #product_concept
      #product_definition
      #product_definition_formation
      #product_definition_group_assignment
      #product_definition_relationship
      #product_group
      #product_in_attachment_slot
      #security_classification
      #validation
      #verification
  ; EndEnumeration
  
  ; IN AP203e2/AP238 Step-NC/AP242
  ; Enumeration string_representation_item_select ; = Select
      #descriptive_representation_item
      #included_text_block
      #structured_text_composition
  ; EndEnumeration
  
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration style_context_select ; = Select   context_dependent_shape_representation ; AP238 Step-NC/AP242   group ; Common   presentation_layer_assignment ; AP203e2/AP214/AP238 Step-NC/AP242   presentation_set ; Common   representation ; Common   representation_item ; Common   representation_relationship ; AP203e2/AP238 Step-NC/AP242   shape_representation_relationship ; AP214; EndEnumeration
  ; IN AP238 Step-NC/AP242
  ; Enumeration styled_item_target ; = Select
      #geometric_representation_item
      #mapped_item
      #representation_or_representation_reference
      #topological_representation_item
  ; EndEnumeration
  
  ; DIFF IN AP214
  ; DIFF IN AP238 Step-NC
  ; DIFF IN AP224
  ; DIFF IN AP232
  ; IN AP214/AP224/AP232/AP238 Step-NC/AP242
  ; Enumeration supported_item ; = Select
      #action
      #action_directive
      #action_method
  ; EndEnumeration
  
  ; DIFF IN AP232
  ; IN AP232/AP242
  ; Enumeration surface_model ; = Select
      #face_based_surface_model
      #shell_based_surface_model
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration surface_or_solid_model ; = Select
      #solid_model
      #surface_model
  ; EndEnumeration
  
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration surface_side_style_select ; = Select   pre_defined_surface_side_style ; AP203e2/AP238 Step-NC/AP242   surface_side_style ; Common; EndEnumeration
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP238 Step-NC
  ; DIFF IN AP232
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; Enumeration surface_style_element_select ; = Select
      #surface_style_boundary
      #surface_style_control_grid
      #surface_style_fill_area
      #surface_style_parameter_line
      #surface_style_rendering
      #surface_style_segmentation_curve
      #surface_style_silhouette
  ; EndEnumeration
      
   ; IN AP242
  ; Enumeration swept_surface_or_solid ; = Select
      #swept_area_solid
      #swept_face_solid
      #swept_surface
  ; EndEnumeration
      
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; Enumeration symbol_style_select ; = Select
      #symbol_colour
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration target_annotated_3d_model_select ; = Select
      #shape_representation_relationship
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration tessellated_edge_or_vertex ; = Select
      #tessellated_edge
      #tessellated_vertex
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration tessellated_surface_item ; = Select
      #tessellated_face
      #tessellated_shell
      #tessellated_solid
      #tessellated_surface_set
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration tessellation_accuracy_parameter_item ; = Select
      #angular_deviation
      #chordal_deviation
      #length_to_height_ratio
      #maximum_edge_length
      #tessellated_facet_long_short_edge_ratio
  ; EndEnumeration
  
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP232; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242; Enumeration text_or_character ; = Select   annotation_text ; Common   annotation_text_character ; AP203e2/AP214/AP232/AP242   composite_text ; Common   defined_character_glyph ; AP214/AP232/AP238 Step-NC/AP242   text_literal ; Common; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP214/AP238 Step-NC/AP242; Enumeration text_string_representation_item ; = Select   annotation_text ; Common   annotation_text_character ; AP203e2/AP214/AP242   axis2_placement ; Common   composite_text ; Common   defined_character_glyph ; AP214/AP238 Step-NC/AP242   text_literal ; Common; EndEnumeration
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; IN AP203e2/AP214/AP238 Step-NC/AP242; Enumeration time_interval_item ; = Select   action ; Common   action_directive ; AP214/AP238 Step-NC/AP242   action_method ; AP214/AP238 Step-NC/AP242   action_property ; AP214/AP238 Step-NC/AP242   action_relationship ; AP214/AP238 Step-NC/AP242   action_request_solution ; AP214/AP238 Step-NC/AP242   alternate_product_relationship ; AP214/AP238 Step-NC/AP242   analysis_assignment ; AP242   applied_action_assignment ; AP214/AP238 Step-NC/AP242   applied_classification_assignment ; AP214/AP238 Step-NC/AP242   applied_person_and_organization_assignment ; AP214/AP238 Step-NC/AP242   approval_status ; AP214/AP238 Step-NC/AP242   assembly_component_usage_substitute ; AP214/AP238 Step-NC/AP242   certification ; AP214/AP238 Step-NC/AP242   class ; AP214/AP238 Step-NC/AP242   class_system ; AP214/AP238 Step-NC/AP242   configuration_design ; AP214/AP238 Step-NC/AP242   configuration_effectivity ; AP214/AP238 Step-NC/AP242   configuration_item ; AP214/AP238 Step-NC/AP242   configured_effectivity_assignment ; AP214/AP238 Step-NC/AP242   contract ; AP214/AP238 Step-NC/AP242   document_file ; AP214/AP238 Step-NC/AP242   draughting_model ; AP214/AP242   drawing_revision ; AP214/AP242   evidence ; AP242   executed_action ; AP214/AP238 Step-NC/AP242   general_property ; AP214/AP238 Step-NC/AP242   material_designation ; AP214/AP238 Step-NC/AP242   mechanical_design_geometric_presentation_representation ; AP214/AP242   organization_relationship ; AP214/AP238 Step-NC/AP242   organizational_project ; AP214/AP238 Step-NC/AP242   person_and_organization ; AP214/AP238 Step-NC/AP242   presentation_area ; AP214/AP242   product ; AP214/AP238 Step-NC/AP242   product_concept ; AP214/AP238 Step-NC/AP242   product_concept_feature ; AP214/AP238 Step-NC/AP242   product_concept_feature_association ; AP214/AP238 Step-NC/AP242   product_concept_feature_category ; AP214/AP238 Step-NC/AP242   product_concept_feature_category_usage ; AP214/AP238 Step-NC/AP242   product_definition ; AP214/AP238 Step-NC/AP242   product_definition_formation ; AP214/AP238 Step-NC/AP242   product_definition_formation_relationship ; AP214/AP238 Step-NC/AP242   product_definition_relationship ; AP214/AP238 Step-NC/AP242   product_definition_substitute ; AP214/AP238 Step-NC/AP242   property_definition ; AP214/AP238 Step-NC/AP242   requirement_for_action_resource ; AP214/AP242   resource_property ; AP214/AP242   security_classification ; AP214/AP238 Step-NC/AP242   security_classification_level ; AP214/AP238 Step-NC/AP242   shape_representation ; AP214/AP238 Step-NC/AP242   time_interval_based_effectivity ; AP203e2/AP242   validation ; AP242   verification ; AP242   verification_relationship ; AP242   versioned_action_request ; AP214/AP238 STEP-NC/AP242; EndEnumeration
  ; IN AP214
  ; Enumeration tolerance_deviation_select ; = Select
      #curve_tolerance_deviation
      #surface_tolerance_deviation
  ; EndEnumeration
  
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP224
  ; IN AP203e2/AP214/AP224/AP238 Step-NC/AP242
  ; Enumeration tolerance_method_definition ; = Select
      #limits_and_fits
      #tolerance_value
  ; EndEnumeration
  
  ; IN AP214
  ; Enumeration tolerance_parameter_select ; = Select
      #curve_tolerance_parameter
      #surface_tolerance_parameter
  ; EndEnumeration
  ; DIFF IN AP224; IN AP214/AP224; Enumeration tolerance_select ; = Select   approximation_tolerance_deviation ; AP214   approximation_tolerance_parameter ; AP214   geometric_tolerance ; AP224   plus_minus_tolerance ; AP224; EndEnumeration
  ; DIFF IN AP238 Step-NC
      
  ; IN AP238 Step-NC/AP242
  ; Enumeration tolerance_value_or_limits_and_fits ; = Select
      #limits_and_fits
      #tolerance_value
  ; EndEnumeration
      
  ; DIFF IN AP238 Step-NC
  ; IN AP238 Step-NC/AP242
  ; Enumeration tolerance_zone_target ; = Select
      #dimensional_location
      #dimensional_size
      #general_datum_reference
      #geometric_tolerance
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP238 Step-NC; DIFF IN AP224; DIFF IN AP232; Enumeration transformation ; = Select   functionally_defined_transformation ; Common   item_defined_transformation ; AP203e2/AP214/AP232/AP238 Step-NC/AP242   list_item_defined_transformation ; AP242   set_item_defined_transformation ; AP242; EndEnumeration
  ; IN AP214
  ; Enumeration translational_range_measure ; = Select
      #length_measure
      #unlimited_range
  ; EndEnumeration
  
  ; DIFF IN AP203e2
  ; IN AP203e2/AP242
  ; Enumeration trim_condition_select ; = Select
      #generalized_surface_select
      #length_measure
      #plane_angle_measure
      #solid_model
  ; EndEnumeration
  
  ; Enumeration trimming_select ; = Select
      #cartesian_point
      #parameter_value
  ; EndEnumeration
  
  ; IN AP238 Step-NC/AP242
  ; Enumeration tuple_space ; = Select
      #extended_tuple_space
      #product_space
  ; EndEnumeration
  
  ; DIFF IN AP224
  ; DIFF IN AP232
  ; Enumeration unit ; = Select
      #derived_unit
      #named_unit
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration used_equivalence_representation_select ; = Select
      #data_equivalence_criteria_representation
      #data_equivalence_inspection_result_representation
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration used_quality_representation_select ; = Select
      #data_quality_criteria_representation
      #data_quality_inspection_result_representation
  ; EndEnumeration
  
  ; IN AP242
  ; Enumeration validation_criteria_or_results_select ; = Select
      #data_equivalence_definition_representation_relationship
  ; EndEnumeration
      
  ; DIFF IN AP214; DIFF IN AP203e2; DIFF IN AP224; DIFF IN AP232; Enumeration value_qualifier ; = Select   maths_value_precision_qualifier ; AP238 Step-NC/AP242   precision_qualifier ; Common   ; Enumeration_qualifier ; Common   uncertainty_qualifier ; AP203e2/AP214/AP224/AP238 Step-NC/AP242   value_format_; Enumeration_qualifier ; AP238 STEP-NC/AP242; EndEnumeration
  ; DIFF IN AP214
  ; DIFF IN AP203e2
  ; DIFF IN AP224
  ; DIFF IN AP232
  ; Enumeration vector_or_direction ; = Select
      #direction
      #vector
  ; EndEnumeration
  
  ; IN AP203e2/AP242
  ; Enumeration work_item ; = Select
      #product_definition_formation
  ; EndEnumeration
      
  ; IN AP238 Step-NC/AP242
  ; Enumeration input_selector = positive_integer;
  ; EndEnumeration
      
  ; IN AP242
  ; Enumeration inspected_shape_element_select = inspected_element_select;
  ;    WHERE
  ;       WR1: Not  'STEP_MERGED_AP_SCHEMA.ASSEMBLY_COMPONENT_USAGE' IN TypeOf SELF)
  ;       wr2: Not  'STEP_MERGED_AP_SCHEMA.AXIS2_PLACEMENT_3D' IN TypeOf SELF)
  ;       wr3: Not  'STEP_MERGED_AP_SCHEMA.CARTESIAN_TRANSFORMATION_OPERATOR_3D' IN TypeOf SELF)
  ;       wr4: Not  'STEP_MERGED_AP_SCHEMA.GLOBAL_UNCERTAINTY_ASSIGNED_CONTEXT' IN TypeOf SELF)
  ;       wr5: Not  'STEP_MERGED_AP_SCHEMA.GLOBAL_UNIT_ASSIGNED_CONTEXT' IN TypeOf SELF)
  ;       wr6: Not  'STEP_MERGED_AP_SCHEMA.GROUP' IN TypeOf SELF)
  ;       wr7: Not  'STEP_MERGED_AP_SCHEMA.PRESENTATION_LAYER_ASSIGNMENT' IN TypeOf SELF)
  ;       wr8: Not  'STEP_MERGED_AP_SCHEMA.REPRESENTATION_ITEM' IN TypeOf SELF)
  ;       wr9: Not  'STEP_MERGED_AP_SCHEMA.STYLED_ITEM' IN TypeOf SELF)
  ; EndEnumeration

EndEnumeration


DataSection
  Constants:
  Data.s "ASSEMBLY_COMPONENT_USAGE"
  Data.s "AXIS2_PLACEMENT_3D"
  Data.s "CARTESIAN_TRANSFORMATION_OPERATOR_3D"
  Data.s "GLOBAL_UNCERTAINTY_ASSIGNED_CONTEXT"
  Data.s "GLOBAL_UNIT_ASSIGNED_CONTEX"
  Data.s "GROUP"
  Data.s "PRESENTATION_LAYER_ASSIGNMENT"
  Data.s "REPRESENTATION_ITEM"
  Data.s "STYLED_ITEM"
  Data.s "REPRESENTATION_CONTEXT"
  Data.s "LENGTH_MEASURE"
EndDataSection


; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 2421
; FirstLine = 2317
; Optimizer
; CPU = 5