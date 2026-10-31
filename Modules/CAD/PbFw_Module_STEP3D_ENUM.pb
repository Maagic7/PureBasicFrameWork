
;- ----------------------------------------
;- ENUM TYPES
;- ----------------------------------------

Enumeration STEP_ENUMERATION_TYPE 1
  ; IN AP242
  ; TYPE a3m_accuracy_TYPE_name = Enumeration OF
       #a3m_accuracy_TYPE_name__others
       #a3m_accuracy_TYPE_name__area_measure
       #a3m_accuracy_TYPE_name__length_measure
       #a3m_accuracy_TYPE_name__plane_angle_measure
       #a3m_accuracy_TYPE_name__volume_measure
  ; END_TYPE         
  ; IN AP242
  ; TYPE a3m_detected_difference_TYPE_name = Enumeration OF
       #a3m_detected_difference_TYPE_name__a3ms_inspected_equivalence_element_select
       #a3m_detected_difference_TYPE_name__assembly_component_usage
       #a3m_detected_difference_TYPE_name__binary_assembly_constraint
       #a3m_detected_difference_TYPE_name__cartesian_point
       #a3m_detected_difference_TYPE_name__context_dependent_shape_representation
       #a3m_detected_difference_TYPE_name__count_measure
       #a3m_detected_difference_TYPE_name__multi_level_reference_designator
       #a3m_detected_difference_TYPE_name__no_element
       #a3m_detected_difference_TYPE_name__others
       #a3m_detected_difference_TYPE_name__volume_measure
       #a3m_detected_difference_TYPE_name__area_measure
       ;#a3m_detected_difference_TYPE_name__cartesian_point
       #a3m_detected_difference_TYPE_name__connected_face_set
       ;#a3m_detected_difference_TYPE_name__count_measure
       #a3m_detected_difference_TYPE_name__edge
       #a3m_detected_difference_TYPE_name__face
       #a3m_detected_difference_TYPE_name__five_count_measure
       #a3m_detected_difference_TYPE_name__four_count_measure
       #a3m_detected_difference_TYPE_name__length_measure
       ;#a3m_detected_difference_TYPE_name__no_element
       ;#a3m_detected_difference_TYPE_name__others
       #a3m_detected_difference_TYPE_name__point_on_curve
       #a3m_detected_difference_TYPE_name__point_on_surface
       #a3m_detected_difference_TYPE_name__several_edges
       #a3m_detected_difference_TYPE_name__several_faces
       #a3m_detected_difference_TYPE_name__three_count_measure
       #a3m_detected_difference_TYPE_name__two_cartesian_points
       #a3m_detected_difference_TYPE_name__two_count_measure
       ;#a3m_detected_difference_TYPE_name__volume_measure
  ; END_TYPE
  ; IN AP242
  ; TYPE a3m_element_TYPE_name = Enumeration OF
       #a3m_element_TYPE_name__others
       #a3m_element_TYPE_name__product_definition_or_reference
       #a3m_element_TYPE_name__shape_representation
       #a3m_element_TYPE_name__connected_edge_set
       #a3m_element_TYPE_name__connected_face_set
       #a3m_element_TYPE_name__external_representation_item
       #a3m_element_TYPE_name__manifold_solid_brep
       ;#a3m_element_TYPE_name__others
       #a3m_element_TYPE_name__point_cloud_dataset
       #a3m_element_TYPE_name__shell_based_surface_model
       #a3m_element_TYPE_name__shell_based_wireframe_model
       #a3m_element_TYPE_name__vertex_point
  ; END_TYPE
  ; IN AP242
  ; TYPE a3m_measured_data_TYPE_name = Enumeration OF
       #a3m_measured_data_TYPE_name__boolean_value
       #a3m_measured_data_TYPE_name__context_dependent_measure
       #a3m_measured_data_TYPE_name__length_measure
       #a3m_measured_data_TYPE_name__length_measure_and_context_dependent_measure
       #a3m_measured_data_TYPE_name__others
       #a3m_measured_data_TYPE_name__plane_angle_measure
       #a3m_measured_data_TYPE_name__volume_measure
       #a3m_measured_data_TYPE_name__area_measure
       ;#a3m_measured_data_TYPE_name__boolean_value
       ;#a3m_measured_data_TYPE_name__length_measure
       ;#a3m_measured_data_TYPE_name__others
       ;#a3m_measured_data_TYPE_name__plane_angle_measure
       ;#a3m_measured_data_TYPE_name__volume_measure
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE actuated_direction = Enumeration OF
       #actuated_direction__bidirectional
       #actuated_direction__positive_only
       #actuated_direction__negative_only
       #actuated_direction__not_actuated
  ; END_TYPE
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; TYPE ahead_or_behind = Enumeration OF
       #ahead_or_behind__ahead
       #ahead_or_behind__exact
       #ahead_or_behind__behind
  ; END_TYPE
  ; DIFF IN AP224
  ; IN AP203e2/AP214/AP224/AP238 Step-NC/AP242
  ; TYPE angle_relator = Enumeration OF
       #angle_relator__equal
       #angle_relator__large
       #angle_relator__small
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE annotation_placeholder_occurrence_role = Enumeration OF
       #annotation_placeholder_occurrence_role__annotation_text
       #annotation_placeholder_occurrence_role__gps_data
  ; END_TYPE
  ; IN AP214
  ; TYPE approximation_method = Enumeration OF
       #approximation_method__chordal_deviation
       #approximation_method__chordal_length
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE area_unit_TYPE = Enumeration OF
       #area_unit_TYPE__circular
       #area_unit_TYPE__cylindrical
       #area_unit_TYPE__rectangular
       #area_unit_TYPE__spherical
       #area_unit_TYPE__square
  ; END_TYPE
  ; DIFF IN AP224
  ; TYPE b_spline_curve_form = Enumeration OF
       #b_spline_curve_form__polyline_form
       #b_spline_curve_form__circular_arc
       #b_spline_curve_form__elliptic_arc
       #b_spline_curve_form__parabolic_arc
       #b_spline_curve_form__hyperbolic_arc
       #b_spline_curve_form__unspecified
  ; END_TYPE
  ; DIFF IN AP224
  ; TYPE b_spline_surface_form = Enumeration OF
       #b_spline_surface_form__plane_surf
       #b_spline_surface_form__cylindrical_surf
       #b_spline_surface_form__conical_surf
       #b_spline_surface_form__spherical_surf
       #b_spline_surface_form__toroidal_surf
       #b_spline_surface_form__surf_of_revolution
       #b_spline_surface_form__ruled_surf
       #b_spline_surface_form__generalised_cone
       #b_spline_surface_form__quadric_surf
       #b_spline_surface_form__surf_of_linear_extrusion
       #b_spline_surface_form__unspecified
  ; END_TYPE
  ; IN AP203e2/AP242
  ; TYPE blend_radius_variation_TYPE = Enumeration OF
       #blend_radius_variation_TYPE__linear_blend
       #blend_radius_variation_TYPE__cubic_blend
       #blend_radius_variation_TYPE__unspecified_blend
  ; END_TYPE
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; TYPE boolean_operator = Enumeration OF
       #boolean_operator__union
       #boolean_operator__intersection
       #boolean_operator__difference
  ; END_TYPE
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; TYPE central_or_parallel = Enumeration OF
       #central_or_parallel__central
       #central_or_parallel__parallel
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE colour_TYPE_enum = Enumeration OF
       #colour_TYPE__rgb8
       #colour_TYPE__rgbt8
  ; END_TYPE
  ; IN AP242
  ; TYPE curves_or_area = Enumeration OF
       #curves_or_area__curves
       #curves_or_area__area
  ; END_TYPE
       
  ; IN AP238 Step-NC/AP242
  ; TYPE datum_reference_modifier_TYPE = Enumeration OF
       #datum_reference_modifier_TYPE__circular_or_cylindrical
       #datum_reference_modifier_TYPE__distance
       #datum_reference_modifier_TYPE__projected
       #datum_reference_modifier_TYPE__spherical
  ; END_TYPE  
  ; IN AP242
  ; TYPE detailed_report_style_TYPE = Enumeration OF
       #detailed_report_style_TYPE__inspected_element
       #detailed_report_style_TYPE__defective_element
  ; END_TYPE
  ; IN AP242
  ; TYPE detailed_report_TYPE = Enumeration OF
       #detailed_report_TYPE__measured_element
       #detailed_report_TYPE__inferior_quality_element
  ; END_TYPE
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; TYPE dimension_extent_usage = Enumeration OF
       #dimension_extent_usage__origin
       #dimension_extent_usage__target
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE directed_tolerance_zone_TYPE = Enumeration OF
       #directed_tolerance_zone_TYPE__perpendicular
       #directed_tolerance_zone_TYPE__parallel
       #directed_tolerance_zone_TYPE__including
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE elementary_function_enumerators = Enumeration OF
       #elementary_function__and
       #elementary_function__or
       #elementary_function__not
       #elementary_function__xor
       #elementary_function__negate_i
       #elementary_function__add_i
       #elementary_function__subtract_i
       #elementary_function__multiply_i
       #elementary_function__divide_i
       #elementary_function__mod_i
       #elementary_function__exponentiate_i
       #elementary_function__eq_i
       #elementary_function__ne_i
       #elementary_function__gt_i
       #elementary_function__lt_i
       #elementary_function__ge_i
       #elementary_function__le_i
       #elementary_function__abs_i
       #elementary_function__max_i
       #elementary_function__min_i
       #elementary_function__if_i
       #elementary_function__negate_r
       #elementary_function__reciprocal_r
       #elementary_function__add_r
       #elementary_function__subtract_r
       #elementary_function__multiply_r
       #elementary_function__divide_r
       #elementary_function__mod_r
       #elementary_function__exponentiate_r
       #elementary_function__exponentiate_ri
       #elementary_function__eq_r
       #elementary_function__ne_r
       #elementary_function__gt_r
       #elementary_function__lt_r
       #elementary_function__ge_r
       #elementary_function__le_r
       #elementary_function__abs_r
       #elementary_function__max_r
       #elementary_function__min_r
       #elementary_function__acos_r
       #elementary_function__asin_r
       #elementary_function__atan2_r
       #elementary_function__cos_r
       #elementary_function__exp_r
       #elementary_function__ln_r
       #elementary_function__log2_r
       #elementary_function__log10_r
       #elementary_function__sin_r
       #elementary_function__sqrt_r
       #elementary_function__tan_r
       #elementary_function__if_r
       #elementary_function__form_c
       #elementary_function__rpart_c
       #elementary_function__ipart_c
       #elementary_function__negate_c
       #elementary_function__reciprocal_c
       #elementary_function__add_c
       #elementary_function__subtract_c
       #elementary_function__multiply_c
       #elementary_function__divide_c
       #elementary_function__exponentiate_c
       #elementary_function__exponentiate_ci
       #elementary_function__eq_c
       #elementary_function__ne_c
       #elementary_function__conjugate_c
       #elementary_function__abs_c
       #elementary_function__arg_c
       #elementary_function__cos_c
       #elementary_function__exp_c
       #elementary_function__ln_c
       #elementary_function__sin_c
       #elementary_function__sqrt_c
       #elementary_function__tan_c
       #elementary_function__if_c
       #elementary_function__subscript_s
       #elementary_function__eq_s
       #elementary_function__ne_s
       #elementary_function__gt_s
       #elementary_function__lt_s
       #elementary_function__ge_s
       #elementary_function__le_s
       #elementary_function__subsequence_s
       #elementary_function__concat_s
       #elementary_function__size_s
       #elementary_function__format
       #elementary_function__value
       #elementary_function__like
       #elementary_function__if_s
       #elementary_function__subscript_b
       #elementary_function__eq_b
       #elementary_function__ne_b
       #elementary_function__gt_b
       #elementary_function__lt_b
       #elementary_function__ge_b
       #elementary_function__le_b
       #elementary_function__subsequence_b
       #elementary_function__concat_b
       #elementary_function__size_b
       #elementary_function__if_b
       #elementary_function__subscript_t
       #elementary_function__eq_t
       #elementary_function__ne_t
       #elementary_function__concat_t
       #elementary_function__size_t
       #elementary_function__entuple
       #elementary_function__detuple
       #elementary_function__insert
       #elementary_function__remove
       #elementary_function__if_t
       #elementary_function__sum_it
       #elementary_function__product_it
       #elementary_function__add_it
       #elementary_function__subtract_it
       #elementary_function__scalar_mult_it
       #elementary_function__dot_prod_it
       #elementary_function__sum_rt
       #elementary_function__product_rt
       #elementary_function__add_rt
       #elementary_function__subtract_rt
       #elementary_function__scalar_mult_rt
       #elementary_function__dot_prod_rt
       #elementary_function__norm_rt
       #elementary_function__sum_ct
       #elementary_function__product_ct
       #elementary_function__add_ct
       #elementary_function__subtract_ct
       #elementary_function__scalar_mult_ct
       #elementary_function__dot_prod_ct
       #elementary_function__norm_ct
       #elementary_function__if
       #elementary_function__ensemble
       #elementary_function__member_of
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE elementary_space_enumerators = Enumeration OF
       #elementary_space__numbers
       #elementary_space__complex_numbers
       #elementary_space__reals
       #elementary_space__integers
       #elementary_space__logicals
       #elementary_space__booleans
       #elementary_space__strings
       #elementary_space__binarys
       #elementary_space__maths_es
       #elementary_space__maths_functions
       #elementary_space__generics
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE extension_options = Enumeration OF
       #extension_options__none
       #extension_options__cont
       #extension_options__cont_right
       #extension_options__cont_left
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE geometric_tolerance_auxiliary_classification_enum = Enumeration OF
       #geometric_tolerance_auxiliary_classification__all_over
       #geometric_tolerance_auxiliary_classification__unless_otherwise_specified
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE geometric_tolerance_modifier = Enumeration OF
       #geometric_tolerance_modifier__any_cross_section
       #geometric_tolerance_modifier__associated_least_square_feature
       #geometric_tolerance_modifier__associated_maximum_inscribed_feature
       #geometric_tolerance_modifier__associated_minimum_inscribed_feature
       #geometric_tolerance_modifier__associated_minmax_feature
       #geometric_tolerance_modifier__associated_tangent_feature
       #geometric_tolerance_modifier__circle_a
       #geometric_tolerance_modifier__common_zone
       #geometric_tolerance_modifier__each_radial_element
       #geometric_tolerance_modifier__free_state
       #geometric_tolerance_modifier__least_material_requirement
       #geometric_tolerance_modifier__line_element
       #geometric_tolerance_modifier__major_diameter
       #geometric_tolerance_modifier__maximum_material_requirement
       #geometric_tolerance_modifier__minor_diameter
       #geometric_tolerance_modifier__not_convex
       #geometric_tolerance_modifier__peak_height
       #geometric_tolerance_modifier__pitch_diameter
       #geometric_tolerance_modifier__reciprocity_requirement
       #geometric_tolerance_modifier__reference_least_square_feature_with_external_material_constraint
       #geometric_tolerance_modifier__reference_least_square_feature_with_internal_material_constraint
       #geometric_tolerance_modifier__reference_least_square_feature_without_constraint
       #geometric_tolerance_modifier__reference_maximum_inscribed_feature
       #geometric_tolerance_modifier__reference_minimax_feature_with_external_material_constraint
       #geometric_tolerance_modifier__reference_minimax_feature_with_internal_material_constraint
       #geometric_tolerance_modifier__reference_minimax_feature_without_constraint
       #geometric_tolerance_modifier__reference_minimum_circumscribed_feature
       #geometric_tolerance_modifier__separate_requirement
       #geometric_tolerance_modifier__standard_deviation
       #geometric_tolerance_modifier__statistical_tolerance
       #geometric_tolerance_modifier__tangent_plane
       #geometric_tolerance_modifier__total_range_deviations
       #geometric_tolerance_modifier__united_feature
       #geometric_tolerance_modifier__valley_depth
  ; END_TYPE
  ; DIFF IN AP214
  ; IN AP214/AP238 Step-NC/AP242
  ; TYPE interpolation_TYPE = Enumeration OF
       #interpolation_TYPE__undefined
       #interpolation_TYPE__discontinuous
       #interpolation_TYPE__synchronous
       #interpolation_TYPE__linear
  ; END_TYPE
  ; TYPE knot_TYPE = Enumeration OF
       #knot_TYPE__uniform
       #knot_TYPE__quasi_uniform
       #knot_TYPE__piecewise_bezier
       #knot_TYPE__unspecified
  ; END_TYPE
  ; DIFF IN AP224
  ; IN AP203e2/AP214/AP224/AP238 Step-NC/AP242
  ; TYPE limit_condition = Enumeration OF
       #limit_condition__maximum_material_condition
       #limit_condition__least_material_condition
       #limit_condition__regardless_of_feature_size
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE linearly_independent_enum = Enumeration OF
       #linearly_independent__independent
       #linearly_independent__not_independent
       #linearly_independent__not_tested
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE locally_refined_spline_TYPE_enum = Enumeration OF
       #locally_refined_spline_TYPE__analysis_suitable_t_spline
       #locally_refined_spline_TYPE__hierarchical_b_spline
       #locally_refined_spline_TYPE__lr_b_spline
       #locally_refined_spline_TYPE__semi_standard_t_spline
       #locally_refined_spline_TYPE__standard_t_spline
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE lower_upper = Enumeration OF
       #lower_upper__lower
       #lower_upper__upper
  ; END_TYPE
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; TYPE marker_TYPE = Enumeration OF
       #marker_TYPE__dot
       #marker_TYPE__x
       #marker_TYPE__plus
       #marker_TYPE__asterisk
       #marker_TYPE__ring
       #marker_TYPE__marker_TYPE__square
       #marker_TYPE__triangle
  ; END_TYPE
  ; IN AP203e2/AP214/AP238 Step-NC/AP242
  ; TYPE null_style = Enumeration OF
       #null_style
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE open_closed = Enumeration OF
       #open_closed__open
       #open_closed__closed
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE ordering_TYPE = Enumeration OF
       #ordering_TYPE__by_rows
       #ordering_TYPE__by_columns
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE oriented_tolerance_zone_TYPE = Enumeration OF
       #oriented_tolerance_zone_TYPE__perpendicular
       #oriented_tolerance_zone_TYPE__parallel
       #oriented_tolerance_zone_TYPE__angular
  ; END_TYPE
  ; IN AP242
  ; TYPE parallel_offset_TYPE = Enumeration OF
       #parallel_offset_TYPE__curve_2d_offset
       #parallel_offset_TYPE__curve_3d_offset
       #parallel_offset_TYPE__surface_offset
  ; END_TYPE
  ; IN AP242
  ; TYPE preferred_ordering = Enumeration OF
       #preferred_ordering__extremity_order
       #preferred_ordering__detected_order
  ; END_TYPE
  ; IN AP242
  ; TYPE preferred_report_ordering = Enumeration OF
       #preferred_report_ordering__in_notable_order
       #preferred_report_ordering__in_detected_order
  ; END_TYPE
  ; DIFF IN AP224
  ; TYPE preferred_surface_curve_representation = Enumeration OF
       #preferred_surface_curve_representation__curve_3d
       #preferred_surface_curve_representation__pcurve_s1
       #preferred_surface_curve_representation__pcurve_s2
  ; END_TYPE
  ; IN AP214
  ; TYPE product_or_presentation_space = Enumeration OF
       #product_or_presentation_space__product_shape_space
       #product_or_presentation_space__presentation_area_space
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE repackage_options = Enumeration OF
       #repackage_options__nochange
       #repackage_options__wrap_as_tuple
       #repackage_options__unwrap_tuple
  ; END_TYPE
  ; IN AP242
  ; TYPE representative_value_TYPE = Enumeration OF
       #representative_value_TYPE__average_value
       #representative_value_TYPE__max_value
       #representative_value_TYPE__min_value
       #representative_value_TYPE__min_max_value
  ; END_TYPE
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; TYPE shading_curve_method = Enumeration OF
       #shading_curve_method__constant_colour
       #shading_curve_method__linear_colour
  ; END_TYPE
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; TYPE shading_surface_method = Enumeration OF
       #shading_surface_method__constant_shading
       #shading_surface_method__colour_shading
       #shading_surface_method__dot_shading
       #shading_surface_method__normal_shading
  ; END_TYPE
  ; DIFF IN AP224
  ; TYPE si_prefix = Enumeration OF
       #si_prefix__exa
       #si_prefix__peta
       #si_prefix__tera
       #si_prefix__giga
       #si_prefix__mega
       #si_prefix__kilo
       #si_prefix__hecto
       #si_prefix__deca
       #si_prefix__deci
       #si_prefix__centi
       #si_prefix__milli
       #si_prefix__micro
       #si_prefix__nano
       #si_prefix__pico
       #si_prefix__femto
       #si_prefix__atto
  ; END_TYPE
  ; DIFF IN AP224
  ; TYPE si_unit_name = Enumeration OF
       #si_unit_name__metre
       #si_unit_name__gram
       #si_unit_name__second
       #si_unit_name__ampere
       #si_unit_name__kelvin
       #si_unit_name__mole
       #si_unit_name__candela
       #si_unit_name__radian
       #si_unit_name__steradian
       #si_unit_name__hertz
       #si_unit_name__newton
       #si_unit_name__pascal
       #si_unit_name__joule
       #si_unit_name__watt
       #si_unit_name__coulomb
       #si_unit_name__volt
       #si_unit_name__farad
       #si_unit_name__ohm
       #si_unit_name__siemens
       #si_unit_name__weber
       #si_unit_name__tesla
       #si_unit_name__henry
       #si_unit_name__degree_celsius
       #si_unit_name__lumen
       #si_unit_name__lux
       #si_unit_name__becquerel
       #si_unit_name__Gray
       #si_unit_name__sievert
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE simple_datum_reference_modifier = Enumeration OF
       #simple_datum_reference_modifier__any_cross_section
       #simple_datum_reference_modifier__any_longitudinal_section
       #simple_datum_reference_modifier__basic
       #simple_datum_reference_modifier__contacting_feature
       #simple_datum_reference_modifier__degree_of_freedom_constraint_u
       #simple_datum_reference_modifier__degree_of_freedom_constraint_v
       #simple_datum_reference_modifier__degree_of_freedom_constraint_w
       #simple_datum_reference_modifier__degree_of_freedom_constraint_x
       #simple_datum_reference_modifier__degree_of_freedom_constraint_y
       #simple_datum_reference_modifier__degree_of_freedom_constraint_z
       #simple_datum_reference_modifier__distance_variable
       #simple_datum_reference_modifier__free_state
       #simple_datum_reference_modifier__least_material_requirement
       #simple_datum_reference_modifier__line
       #simple_datum_reference_modifier__major_diameter
       #simple_datum_reference_modifier__maximum_material_requirement
       #simple_datum_reference_modifier__minor_diameter
       #simple_datum_reference_modifier__orientation
       #simple_datum_reference_modifier__pitch_diameter
       #simple_datum_reference_modifier__plane
       #simple_datum_reference_modifier__point
       #simple_datum_reference_modifier__translation
  ; END_TYPE
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; TYPE source = Enumeration OF
       #source__made
       #source__bought
       #source__not_known
  ; END_TYPE
  ; IN AP238 Step-NC/AP242
  ; TYPE space_constraint_TYPE = Enumeration OF
       #space_constraint_TYPE__sc_equal
       #space_constraint_TYPE__sc_subspace
       #space_constraint_TYPE__sc_member
  ; END_TYPE
  ; IN AP242
  ; TYPE statistical_value_TYPE = Enumeration OF
       #statistical_value_TYPE__number_of_inspected_instances
       #statistical_value_TYPE__number_of_quality_defects_detected
  ; END_TYPE
  ; IN AP242
  ; TYPE summary_report_style_TYPE = Enumeration OF
       #summary_report_style_TYPE__conclusion
       #summary_report_style_TYPE__number_of_defects
       #summary_report_style_TYPE__number_of_inspections
  ; END_TYPE
  ; IN AP242
  ; TYPE summary_report_TYPE = Enumeration OF
       #summary_report_TYPE__unspecified
       #summary_report_TYPE__conclusion_only
       #summary_report_TYPE__number_of_quality_defects
       #summary_report_TYPE__number_of_inspections_and_conclusion
       #summary_report_TYPE__ull_statistics
  ; END_TYPE
  ; IN AP242
  ; TYPE surface_boundary_TYPE = Enumeration OF
       #surface_boundary_TYPE__u_parameter_min
       #surface_boundary_TYPE__v_parameter_min
       #surface_boundary_TYPE__u_parameter_max
       #surface_boundary_TYPE__v_parameter_max
  ; END_TYPE
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; TYPE surface_side = Enumeration OF
       #surface_side__positive
       #surface_side__negative
       #surface_side__both
  ; END_TYPE
       
   ; IN AP238 Step-NC/AP242
  ; TYPE symmetry_TYPE = Enumeration OF
       #symmetry_TYPE__identity
       #symmetry_TYPE__skew
       #symmetry_TYPE__hermitian
       #symmetry_TYPE__skew_hermitian
  ; END_TYPE
  ; IN AP242
  ; TYPE tangent_contact_TYPE = Enumeration OF
       #tangent_contact_TYPE__point_contact
       #tangent_contact_TYPE__curve_contact
       #tangent_contact_TYPE__surface_contact
  ; END_TYPE
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; TYPE text_path = Enumeration OF
       #text_path__left
       #text_path__right
       #text_path__up
       #text_path__down
  ; END_TYPE
  ; IN AP242
  ; TYPE texture_file_TYPE = Enumeration OF
       #texture_file_TYPE__jpeg
       #texture_file_TYPE__png
       #texture_file_TYPE__gif
       #texture_file_TYPE__tiff
       #texture_file_TYPE__bmp
       #texture_file_TYPE__dds
       #texture_file_TYPE__tga
       #texture_file_TYPE__other
  ; END_TYPE
  ; DIFF IN AP224
  ; TYPE transition_code = Enumeration OF
       #transition_code__discontinuous
       #transition_code__continuous
       #transition_code__cont_same_gradient
       #transition_code__cont_same_gradient_same_curvature
  ; END_TYPE
  ; IN AP203e2/AP242
  ; TYPE trim_intent = Enumeration OF
       #trim_intent__blind
       #trim_intent__offset
       #trim_intent__through_all
       #trim_intent__unspecified
       #trim_intent__up_to_next
  ; END_TYPE
  ; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
  ; TYPE trimming_preference = Enumeration OF
       #trimming_preference__cartesian
       #trimming_preference__parameter
       #trimming_preference__unspecified
  ; END_TYPE
  ; IN AP242
  ; TYPE u_or_v_parameter = Enumeration OF
       #u_parameter
       #v_parameter
  ; END_TYPE
  ; IN AP214
  ; TYPE unlimited_range = Enumeration OF
       #unlimited
  ; END_TYPE
  ; IN AP214/AP238 Step-NC/AP242
  ; TYPE ypr_enumeration = Enumeration OF
       #ypr__yaw
       #ypr__pitch
       #ypr__roll
  ; END_TYPE

EndEnumeration

;- ----------------------------------------
;- REAL TYPES
;- ----------------------------------------

; IN AP203e2/AP238 Step-NC/AP242
Structure absorbed_dose_measure
  d.d
EndStructure
; IN AP203e2/AP238 Step-NC/AP242
Structure acceleration_measure
  d.d
EndStructure


; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
Structure amount_of_substance_measure
  d.d 
EndStructure

; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
Structure area_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure capacitance_measure 
  d.d
EndStructure

; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
Structure celsius_temperature_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure conductance_measure
  d.d
EndStructure

Structure context_dependent_measure
  d.d
EndStructure

; IN AP214
Structure curve_tolerance_parameter
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure dose_equivalent_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure electric_charge_measure
  d.d
EndStructure

; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
Structure electric_current_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure electric_potential_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure energy_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure force_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure frequency_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure illuminance_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure inductance_measure
  d.d
EndStructure

Structure length_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure luminous_flux_measure
  d.d
EndStructure

; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
Structure luminous_intensity_measure
  d.d
EndStructure


; IN AP203e2/AP238 Step-NC/AP242
Structure magnetic_flux_density_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure magnetic_flux_measure
  d.d
EndStructure

; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
Structure mass_measure
  d.d
EndStructure

; IN AP238 Step-NC/AP242
Structure maths_real
  d.d
EndStructure

; IN AP242
Structure non_negative_real
  d.d
EndStructure

Structure parameter_value
  d.d
EndStructure

Structure plane_angle_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure power_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure pressure_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure radioactivity_measure
  d.d
EndStructure

Structure ratio_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure resistance_measure
  d.d
EndStructure

; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
Structure second_in_minute
  d.d
EndStructure

; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
Structure solid_angle_measure
  d.d
EndStructure

; IN AP214
Structure surface_tolerance_parameter
  d.d
EndStructure

; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
Structure thermodynamic_temperature_measure
  d.d
EndStructure

; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
Structure time_measure
  d.d
EndStructure

; IN AP203e2/AP238 Step-NC/AP242
Structure velocity_measure
  d.d
EndStructure

; IN AP203e2/AP214/AP232/AP238 Step-NC/AP242
Structure volume_measure
  d.d
EndStructure

; IN AP238 Step-NC/AP242
Structure spline_knot_values
  List lst.d()  ; [2:?] OF REAL;
EndStructure

DataSection
TYPES:
  Data.s "a3m_accuracy_type_name"
  Data.s "a3m_detected_difference_type_name"
  Data.s "a3m_element_type_name"
  Data.s "a3m_equivalence_assessment_specification_select"
  Data.s "a3m_measured_data_type_name"
  Data.s "a3ma_accuracy_type_name"
  Data.s "a3ma_detected_difference_type_name"
  Data.s "a3ma_element_type_name"
  Data.s "a3ma_measured_data_type_name"
  Data.s "a3ms_accuracy_type_name"
  Data.s "a3ms_detected_difference_type_name"
  Data.s "a3ms_element_type_name"
  Data.s "a3ms_inspected_equivalence_element_select"
  Data.s "a3ms_measured_data_type_name"
  Data.s "absorbed_dose_measure"
  Data.s "acceleration_measure"
  Data.s "accuracy_associated_target_select"
  Data.s "action_item"
  Data.s "action_items"
  Data.s "action_method_items"
  Data.s "action_request_item"
  Data.s "actuated_direction"
  Data.s "ahead_or_behind"
  Data.s "amount_of_substance_measure"
  Data.s "analysed_item"
  Data.s "angle_direction_reference_select"
  Data.s "angle_direction_reference_with_a2p3d_select"
  Data.s "angle_relator"
  Data.s "angular_deviation"
  Data.s "annotation_placeholder_occurrence_role"
  Data.s "annotation_plane_element"
  Data.s "annotation_representation_select"
  Data.s "annotation_symbol_occurrence_item"
  Data.s "annotation_text_occurrence_item"
  Data.s "ap242_assignment_object_select"
  Data.s "approval_item"
  Data.s "approximation_method"
  Data.s "area_measure"
  Data.s "area_or_view"
  Data.s "area_unit_type"
  Data.s "assignment_object_select"
  Data.s "atom_based_tuple"
  Data.s "atom_based_value"
  Data.s "attribute_classification_item"
  Data.s "attribute_identifier"
  Data.s "attribute_language_item"
  Data.s "attribute_select"
  Data.s "attribute_type"
  Data.s "axial_geometry_constraint_element"
  Data.s "axis2_placement"
  Data.s "b_spline_curve_form"
  Data.s "b_spline_or_composite_curve_select"
  Data.s "b_spline_or_rectangular_composite_surface_select"
  Data.s "b_spline_surface_form"
  Data.s "base_solid_select"
  Data.s "basis_11_direction_member"
  Data.s "blend_end_condition_select"
  Data.s "blend_radius_variation_type"
  Data.s "boolean_operand"
  Data.s "boolean_operand_2d"
  Data.s "boolean_operator"
  Data.s "boolean_value"
  Data.s "bounded_primitive_2d"
  Data.s "box_characteristic_select"
  Data.s "box_height"
  Data.s "box_rotate_angle"
  Data.s "box_slant_angle"
  Data.s "box_width"
  Data.s "camera_model_d3_multi_clipping_interection_select"
  Data.s "camera_model_d3_multi_clipping_intersection_select"
  Data.s "camera_model_d3_multi_clipping_union_select"
  Data.s "capacitance_measure"
  Data.s "category_usage_item"
  Data.s "celsius_temperature_measure"
  Data.s "central_or_parallel"
  Data.s "certification_item"
  Data.s "chained_representation_link"
  Data.s "change_management_object"
  Data.s "change_relationship_select"
  Data.s "change_request_item"
  Data.s "character_spacing_select"
  Data.s "character_style_select"
  Data.s "characterized_action_definition"
  Data.s "characterized_definition"
  Data.s "characterized_item"
  Data.s "characterized_material_property"
  Data.s "characterized_product_composition_value"
  Data.s "characterized_product_definition"
  Data.s "characterized_property_representation"
  Data.s "characterized_resource_definition"
  Data.s "chordal_deviation"
  Data.s "class_usage_effectivity_context_item"
  Data.s "classification_item"
  Data.s "classified_item"
  Data.s "closed_or_open_shell_select"
  Data.s "colour_type_enum"
  Data.s "common_datum_list"
  Data.s "compound_inner_area_boundary"
  Data.s "compound_item_definition"
  Data.s "conductance_measure"
  Data.s "configuration_design_item"
  Data.s "configured_effectivity_context_item"
  Data.s "configured_effectivity_item"
  Data.s "connected_edge_with_length_set_items"
  Data.s "constraint_group_member"
  Data.s "constructive_geometry_representation_or_shape_represenation"
  Data.s "constructive_geometry_representation_or_shape_representation"
  Data.s "context_dependent_measure"
  Data.s "contract_item"
  Data.s "count_measure"
  Data.s "csg_2d_area_select"
  Data.s "csg_2d_shape_select"
  Data.s "csg_primitive"
  Data.s "csg_select"
  Data.s "csg_select_2d"
  Data.s "current_element_assignment_select"
  Data.s "curve_font_or_scaled_curve_font_select"
  Data.s "curve_on_surface"
  Data.s "curve_or_annotation_curve_occurrence"
  Data.s "curve_or_curve_set"
  Data.s "curve_or_render"
  Data.s "curve_or_surface_constraint_element"
  Data.s "curve_style_font_select"
  Data.s "curve_tolerance_deviation"
  Data.s "curve_tolerance_parameter"
  Data.s "curves_or_area"
  Data.s "date_and_time_item"
  Data.s "date_item"
  Data.s "date_time_or_event_occurrence"
  Data.s "date_time_select"
  Data.s "datum_or_common_datum"
  Data.s "datum_reference_modifier"
  Data.s "datum_reference_modifier_type"
  Data.s "datum_system_or_reference"
  Data.s "day_in_month_number"
  Data.s "day_in_week_number"
  Data.s "day_in_year_number"
  Data.s "defined_glyph_select"
  Data.s "defined_symbol_select"
  Data.s "derived_property_select"
  Data.s "description_attribute_select"
  Data.s "description_item"
  Data.s "descriptive_measure"
  Data.s "detailed_report_style_type"
  Data.s "detailed_report_type"
  Data.s "dimension_count"
  Data.s "dimension_extent_usage"
  Data.s "dimensional_characteristic"
  Data.s "directed_tolerance_zone_type"
  Data.s "direction_count_select"
  Data.s "document_identifier_assigned_item"
  Data.s "document_reference_item"
  Data.s "dose_equivalent_measure"
  Data.s "draughting_approval_item"
  Data.s "draughting_callout_element"
  Data.s "draughting_model_item_association_select"
  Data.s "draughting_model_item_definition"
  Data.s "draughting_model_item_select"
  Data.s "draughting_subfigure_representation_item"
  Data.s "draughting_symbol_representation_item"
  Data.s "draughting_titled_item"
  Data.s "edge_or_curve"
  Data.s "effectivity_context_item"
  Data.s "effectivity_item"
  Data.s "electric_charge_measure"
  Data.s "electric_current_measure"
  Data.s "electric_potential_measure"
  Data.s "elementary_function_enumerators"
  Data.s "elementary_space_enumerators"
  Data.s "energy_measure"
  Data.s "equivalence_detected_difference_select"
  Data.s "equivalence_measured_value_select"
  Data.s "equivalence_product_data_select"
  Data.s "event_occurrence_item"
  Data.s "evidence_item"
  Data.s "expression_element"
  Data.s "expression_extension_select"
  Data.s "extension_options"
  Data.s "external_identification_item"
  Data.s "face_or_surface"
  Data.s "fill_area_style_tile_shape_select"
  Data.s "fill_style_select"
  Data.s "font_select"
  Data.s "force_measure"
  Data.s "founded_item_select"
  Data.s "frequency_measure"
  Data.s "general_organizational_data_select"
  Data.s "generalized_surface_select"
  Data.s "generic_property_definition_select"
  Data.s "geometric_constraint_element"
  Data.s "geometric_item_specific_usage_select"
  Data.s "geometric_model_item"
  Data.s "geometric_set_select"
  Data.s "geometric_tolerance_auxiliary_classification_enum"
  Data.s "geometric_tolerance_modifier"
  Data.s "geometric_tolerance_target"
  Data.s "gps_filtration_specification_target"
  Data.s "gps_filtration_type"
  Data.s "group_item"
  Data.s "groupable_item"
  Data.s "hour_in_day"
  Data.s "id_attribute_select"
  Data.s "identification_item"
  Data.s "identifier"
  Data.s "idrm_marked_item"
  Data.s "illuminance_measure"
  Data.s "inductance_measure"
  Data.s "input_selector"
  Data.s "inspected_ecdq_element_select"
  Data.s "inspected_element_select"
  Data.s "inspected_equivalence_element_select"
  Data.s "inspected_shape_element_select"
  Data.s "instance_usage_context_select"
  Data.s "internal_or_reflected_shape_aspect"
  Data.s "interpolation_type"
  Data.s "invisibility_context"
  Data.s "invisible_item"
  Data.s "ir_usage_item"
  Data.s "item_identified_representation_usage_definition"
  Data.s "item_identified_representation_usage_select"
  Data.s "kinematic_analysis_definition"
  Data.s "kinematic_frame_background"
  Data.s "kinematic_link_representation_items"
  Data.s "kinematic_result"
  Data.s "kinematic_topology_representation_select"
  Data.s "knot_type"
  Data.s "label"
  Data.s "language_item"
  Data.s "layered_item"
  Data.s "length_measure"
  Data.s "length_or_plane_angle_measure_with_unit_select"
  Data.s "length_to_height_ratio"
  Data.s "limit_condition"
  Data.s "linear_geometry_constraint_element"
  Data.s "linearly_independent_enum"
  Data.s "link_or_shape_representation"
  Data.s "list_item_defined_transformation"
  Data.s "list_of_reversible_topology_item"
  Data.s "list_representation_item"
  Data.s "locally_refined_spline_type_enum"
  Data.s "location_in_aggregate_item"
  Data.s "location_item"
  Data.s "location_of_extreme_value_select"
  Data.s "location_representation_item"
  Data.s "lower_upper"
  Data.s "luminous_flux_measure"
  Data.s "luminous_intensity_measure"
  Data.s "machining_feature_definition"
  Data.s "magnetic_flux_density_measure"
  Data.s "magnetic_flux_measure"
  Data.s "marker_select"
  Data.s "marker_type"
  Data.s "mass_measure"
  Data.s "maths_atom"
  Data.s "maths_binary"
  Data.s "maths_boolean"
  Data.s "maths_enum_atom"
  Data.s "maths_expression"
  Data.s "maths_function_select"
  Data.s "maths_integer"
  Data.s "maths_logical"
  Data.s "maths_number"
  Data.s "maths_real"
  Data.s "maths_simple_atom"
  Data.s "maths_space_or_function"
  Data.s "maths_string"
  Data.s "maths_tuple"
  Data.s "maths_value"
  Data.s "maximum_edge_length"
  Data.s "measure_value"
  Data.s "measured_value_select"
  Data.s "mechanical_design_and_draughting_relationship_select"
  Data.s "mechanical_design_geometric_presentation_area_items"
  Data.s "mechanical_design_geometric_presentation_representation_items"
  Data.s "mechanical_design_shaded_presentation_area_items"
  Data.s "mechanical_design_shaded_presentation_representation_items"
  Data.s "message"
  Data.s "minute_in_hour"
  Data.s "month_in_year_number"
  Data.s "motion_parameter_measure"
  Data.s "multi_language_attribute_item"
  Data.s "multi_or_next_assembly_usage_occurrence"
  Data.s "name_attribute_select"
  Data.s "name_item"
  Data.s "non_negative_length_measure"
  Data.s "non_negative_real"
  Data.s "nonnegative_integer"
  Data.s "null_style"
  Data.s "numeric_measure"
  Data.s "one_or_two"
  Data.s "open_closed"
  Data.s "ordered_part_item"
  Data.s "ordering_type"
  Data.s "organization_item"
  Data.s "organization_type_item"
  Data.s "orientation_basis_select"
  Data.s "oriented_tolerance_zone_type"
  Data.s "parallel_offset_type"
  Data.s "parameter_value"
  Data.s "path_or_composite_curve"
  Data.s "pcurve_or_surface"
  Data.s "person_and_organization_item"
  Data.s "person_organization_select"
  Data.s "picture_representation_item_select"
  Data.s "planar_curve_select"
  Data.s "plane_angle_measure"
  Data.s "plane_or_planar_box"
  Data.s "point_and_vector_member"
  Data.s "point_and_vector_members"
  Data.s "point_array_members"
  Data.s "point_cloud_set_or_superset"
  Data.s "point_curve_or_surface_constraint_element"
  Data.s "point_path_members"
  Data.s "point_placement_shape_representation_item"
  Data.s "positive_integer"
  Data.s "positive_length_measure"
  Data.s "positive_plane_angle_measure"
  Data.s "positive_ratio_measure"
  Data.s "power_measure"
  Data.s "preferred_ordering"
  Data.s "preferred_report_ordering"
  Data.s "preferred_surface_curve_representation"
  Data.s "presentable_text"
  Data.s "presentation_representation_select"
  Data.s "presentation_size_assignment_select"
  Data.s "presentation_style_select"
  Data.s "presented_item_select"
  Data.s "pressure_measure"
  Data.s "previous_element_assignment_select"
  Data.s "product_definition_occurrence_or_reference"
  Data.s "product_definition_or_assembly_relationship"
  Data.s "product_definition_or_breakdown_element_usage"
  Data.s "product_definition_or_product_definition_relationship"
  Data.s "product_definition_or_reference"
  Data.s "product_definition_or_reference_or_occurrence"
  Data.s "product_or_formation_or_definition"
  Data.s "product_or_presentation_space"
  Data.s "product_select"
  Data.s "product_space"
  Data.s "project_item"
  Data.s "property_or_shape_select"
  Data.s "property_variable_rep_select"
  Data.s "radial_geometry_constraint_element"
  Data.s "radioactivity_measure"
  Data.s "ratio_measure"
  Data.s "real_interval"
  Data.s "rendering_properties_select"
  Data.s "repackage_options"
  Data.s "representation_or_representation_reference"
  Data.s "representation_proxy_select"
  Data.s "representative_value_type"
  Data.s "represented_definition"
  Data.s "requirement_assigned_item"
  Data.s "requirement_satisfaction_item"
  Data.s "requirement_source_item"
  Data.s "resistance_measure"
  Data.s "reversible_topology"
  Data.s "reversible_topology_item"
  Data.s "rigid_placement"
  Data.s "role_select"
  Data.s "rotational_range_measure"
  Data.s "rule_superseded_item"
  Data.s "same_as_item"
  Data.s "second_in_minute"
  Data.s "security_classification_item"
  Data.s "set_inner_area_boundary"
  Data.s "set_item_defined_transformation"
  Data.s "set_of_reversible_topology_item"
  Data.s "set_representation_item"
  Data.s "shading_curve_method"
  Data.s "shading_surface_method"
  Data.s "shape_aspect_or_characterized_object"
  Data.s "shape_data_quality_assessment_specification_select"
  Data.s "shape_data_quality_value_limit_type_select"
  Data.s "shape_definition"
  Data.s "shape_dimension_representation_item"
  Data.s "shape_model"
  Data.s "shape_representation_item"
  Data.s "shape_representation_with_parameters_items"
  Data.s "shell"
  Data.s "si_prefix"
  Data.s "si_unit_name"
  Data.s "simple_datum_reference_modifier"
  Data.s "size_select"
  Data.s "sketch_basis_select"
  Data.s "sketch_element_select"
  Data.s "sketch_type_select"
  Data.s "solid_angle_measure"
  Data.s "source"
  Data.s "source_item"
  Data.s "space_constraint_type"
  Data.s "spatial_rotation"
  Data.s "specified_item"
  Data.s "spherical_pair_select"
  Data.s "spline_knot_values"
  Data.s "start_request_item"
  Data.s "state_observed_of_item"
  Data.s "state_type_of_item"
  Data.s "statistical_value_type"
  Data.s "string_representation_item_select"
  Data.s "style_context_select"
  Data.s "styled_item_target"
  Data.s "summary_report_style_type"
  Data.s "summary_report_type"
  Data.s "supported_item"
  Data.s "surface_boundary_type"
  Data.s "surface_model"
  Data.s "surface_or_solid_model"
  Data.s "surface_side"
  Data.s "surface_side_style_select"
  Data.s "surface_style_element_select"
  Data.s "surface_tolerance_deviation"
  Data.s "surface_tolerance_parameter"
  Data.s "swept_surface_or_solid"
  Data.s "symbol_style_select"
  Data.s "symmetry_type"
  Data.s "tangent_contact_type"
  Data.s "target_annotated_3d_model_select"
  Data.s "tessellated_edge_or_vertex"
  Data.s "tessellated_facet_long_short_edge_ratio"
  Data.s "tessellated_surface_item"
  Data.s "tessellation_accuracy_parameter_item"
  Data.s "text"
  Data.s "text_alignment"
  Data.s "text_delineation"
  Data.s "text_or_character"
  Data.s "text_path"
  Data.s "text_string_representation_item"
  Data.s "texture_file_type"
  Data.s "thermodynamic_temperature_measure"
  Data.s "time_interval_item"
  Data.s "time_measure"
  Data.s "tolerance_deviation_select"
  Data.s "tolerance_method_definition"
  Data.s "tolerance_parameter_select"
  Data.s "tolerance_select"
  Data.s "tolerance_value_or_limits_and_fits"
  Data.s "tolerance_zone_target"
  Data.s "transformation"
  Data.s "transition_code"
  Data.s "translational_range_measure"
  Data.s "trim_condition_select"
  Data.s "trim_intent"
  Data.s "trimming_preference"
  Data.s "trimming_select"
  Data.s "tuple_space"
  Data.s "u_direction_count"
  Data.s "u_or_v_parameter"
  Data.s "unit"
  Data.s "unlimited_range"
  Data.s "unsigned_8_bit_integer"
  Data.s "used_equivalence_representation_select"
  Data.s "used_quality_representation_select"
  Data.s "v_direction_count"
  Data.s "validation_criteria_or_results_select"
  Data.s "value_format_type"
  Data.s "value_qualifier"
  Data.s "vector_or_direction"
  Data.s "velocity_measure"
  Data.s "volume_measure"
  Data.s "week_in_year_number"
  Data.s "work_item"
  Data.s "year_number"
  Data.s "ypr_enumeration"
  Data.s "ypr_rotation"
  Data.s "zero_or_one"
  Data.s "---", "---"
EndDataSection
; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 942
; FirstLine = 906
; Optimizer
; CPU = 5