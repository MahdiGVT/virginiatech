//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "VirginiatechTestApp.h"
#include "VirginiatechApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
VirginiatechTestApp::validParams()
{
  InputParameters params = VirginiatechApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

VirginiatechTestApp::VirginiatechTestApp(InputParameters parameters) : MooseApp(parameters)
{
  VirginiatechTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

VirginiatechTestApp::~VirginiatechTestApp() {}

void
VirginiatechTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  VirginiatechApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"VirginiatechTestApp"});
    Registry::registerActionsTo(af, {"VirginiatechTestApp"});
  }
}

void
VirginiatechTestApp::registerApps()
{
  registerApp(VirginiatechApp);
  registerApp(VirginiatechTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
VirginiatechTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  VirginiatechTestApp::registerAll(f, af, s);
}
extern "C" void
VirginiatechTestApp__registerApps()
{
  VirginiatechTestApp::registerApps();
}
