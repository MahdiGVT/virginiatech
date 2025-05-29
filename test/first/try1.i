# Phase-field modeling for pH-dependent corrosion of iron
# Based on Tsuyuki et al. supplementary information

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  ny = 100
  xmin = 0
  xmax = 1e-3  # 1 mm domain
  ymin = 0
  ymax = 1e-3  # 1 mm domain
  elem_type = QUAD4
[]

[GlobalParams]
  op_num = 1
  var_name_base = eta
[]

[Variables]
  # Phase field variable (xi in paper)
  [./xi]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]
  
  # Chemical species concentrations
  [./c_H]     # H+ concentration
    order = FIRST
    family = LAGRANGE
    initial_condition = 1e-7  # pH = 7
  [../]
  
  [./c_OH]    # OH- concentration
    order = FIRST
    family = LAGRANGE
    initial_condition = 1e-7  # pH = 7
  [../]
  
  [./c_Fe2]   # Fe2+ concentration
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]
  
  [./c_H2O]   # H2O concentration
    order = FIRST
    family = LAGRANGE
    initial_condition = 55.5  # mol/L
  [../]
  
  # Electrostatic potential
  [./phi]
    order = FIRST
    family = LAGRANGE
    initial_condition = 0.0
  [../]
[]

[AuxVariables]
  [./pH]
    order = CONSTANT
    family = MONOMIAL
  [../]
  
  [./overpotential]
    order = CONSTANT
    family = MONOMIAL
  [../]
  
  [./current_density]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

[ICs]
  # Initialize iron phase (xi = 1) in bottom half
  [./xi_IC]
    type = FunctionIC
    variable = xi
    function = 'if(y < 0.5e-3, 1.0, 0.0)'
  [../]
[]

[Kernels]
  # Phase field evolution equation (Eq. S28)
  [./xi_time]
    type = TimeDerivative
    variable = xi
  [../]
  
  [./xi_interface]
    type = ACInterface
    variable = xi
    kappa_name = kappa
  [../]
  
  [./xi_bulk]
    type = AllenCahn
    variable = xi
    f_name = f_bulk
  [../]
  
  [./xi_corrosion]
    type = CorrosionReactionKernel  # Custom kernel needed
    variable = xi
    c_H = c_H
    c_OH = c_OH
    c_Fe2 = c_Fe2
    c_H2O = c_H2O
    overpotential = overpotential
  [../]
  
  # Species transport equations
  [./c_H_time]
    type = TimeDerivative
    variable = c_H
  [../]
  
  [./c_H_diff]
    type = MatDiffusion
    variable = c_H
    diffusivity = D_H
  [../]
  
  [./c_OH_time]
    type = TimeDerivative
    variable = c_OH
  [../]
  
  [./c_OH_diff]
    type = MatDiffusion
    variable = c_OH
    diffusivity = D_OH
  [../]
  
  [./c_Fe2_time]
    type = TimeDerivative
    variable = c_Fe2
  [../]
  
  [./c_Fe2_diff]
    type = MatDiffusion
    variable = c_Fe2
    diffusivity = D_Fe2
  [../]
  
  [./c_H2O_time]
    type = TimeDerivative
    variable = c_H2O
  [../]
  
  [./c_H2O_diff]
    type = MatDiffusion
    variable = c_H2O
    diffusivity = D_H2O
  [../]
  
  # Electrostatic potential (Laplace equation)
  [./phi_laplace]
    type = Diffusion
    variable = phi
  [../]
[]

[AuxKernels]
  [./pH_calc]
    type = ParsedAux
    variable = pH
    args = 'c_H'
    function = '-log10(c_H)'
  [../]
  
  [./overpotential_calc]
    type = OverpotentialAux  # Custom aux kernel needed
    variable = overpotential
    phi = phi
    c_H = c_H
    c_OH = c_OH
    c_Fe2 = c_Fe2
  [../]
[]

[Materials]
  # Electrochemical parameters
  [./constants]
    type = GenericConstantMaterial
    prop_names = 'R T F z_Fe z_H z_OH alpha k0 K1 K3 kappa L_sigma L_eta'
    prop_values = '8.314 333.15 96485 2 1 -1 0.5 1e-6 1e10 1e-10 1e-6 1e-8 1e-8'
  [../]
  
  # Diffusion coefficients
  [./diffusivities]
    type = GenericConstantMaterial
    prop_names = 'D_H D_OH D_Fe2 D_H2O'
    prop_values = '9.3e-9 5.3e-9 0.7e-9 2.3e-9'  # m²/s at 60°C
  [../]
  
  # Double well potential
  [./f_bulk]
    type = MathEBFreeEnergy
    property_name = f_bulk
    c = xi
  [../]
  
  # Interpolation function L(xi) = 6*xi*(1-xi)
  [./interpolation]
    type = ParsedMaterial
    property_name = L_xi
    args = 'xi'
    function = '6*xi*(1-xi)'
  [../]
[]

[BCs]
  # Phase field - no flux at boundaries
  [./xi_neumann]
    type = NeumannBC
    variable = xi
    boundary = 'left right top bottom'
    value = 0
  [../]
  
  # Species concentrations - bulk conditions at top boundary
  [./c_H_bulk]
    type = DirichletBC
    variable = c_H
    boundary = 'top'
    value = 1e-7  # pH = 7
  [../]
  
  [./c_OH_bulk]
    type = DirichletBC
    variable = c_OH
    boundary = 'top'
    value = 1e-7  # pH = 7
  [../]
  
  [./c_Fe2_bulk]
    type = DirichletBC
    variable = c_Fe2
    boundary = 'top'
    value = 0.0
  [../]
  
  # No flux at other boundaries
  [./species_neumann]
    type = NeumannBC
    variable = 'c_H c_OH c_Fe2 c_H2O'
    boundary = 'left right bottom'
    value = 0
  [../]
  
  # Electrostatic potential
  [./phi_electrode]
    type = DirichletBC
    variable = phi
    boundary = 'bottom'
    value = -0.1  # Applied potential vs reference
  [../]
  
  [./phi_solution]
    type = DirichletBC
    variable = phi
    boundary = 'top'
    value = 0.0  # Reference potential
  [../]
[]

[Postprocessors]
  # Monitor pit depth
  [./pit_depth]
    type = ElementExtremeValue
    variable = xi
    value_type = min
  [../]
  
  # Monitor pH at interface
  [./min_pH]
    type = ElementExtremeValue
    variable = pH
    value_type = min
  [../]
  
  # Total Fe2+ production
  [./total_Fe2]
    type = ElementIntegralVariablePostprocessor
    variable = c_Fe2
  [../]
  
  # Interface area
  [./interface_area]
    type = InterfaceAreaPostprocessor
    variable = xi
    threshold = 0.5
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  solve_type = NEWTON
  
  # Time stepping
  start_time = 0.0
  end_time = 2.4  # 2.4 seconds as in paper
  dt = 0.001
  dtmin = 1e-6
  dtmax = 0.01
  
  # Solver parameters
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value = 'hypre boomeramg 31'
  
  # Convergence criteria
  nl_max_its = 15
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-10
  
  # Adaptive time stepping
  [./TimeStepper]
    type = IterationAdaptiveDT
    dt = 0.001
    optimal_iterations = 8
    iteration_window = 2
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  print_linear_residuals = false
  
  [./console]
    type = Console
    print_mesh_changed_info = false
  [../]
  
  [./exodus_out]
    type = Exodus
    file_base = corrosion_out
    interval = 10
  [../]
  
  [./csv_out]
    type = CSV
    file_base = corrosion_postprocessors
  [../]
[]

[Debug]
  show_var_residual_norms = true
[]
