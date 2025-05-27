#include "VirginiatechApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
VirginiatechApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

VirginiatechApp::VirginiatechApp(InputParameters parameters) : MooseApp(parameters)
{
  VirginiatechApp::registerAll(_factory, _action_factory, _syntax);
}

VirginiatechApp::~VirginiatechApp() {}

void
VirginiatechApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<VirginiatechApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"VirginiatechApp"});
  Registry::registerActionsTo(af, {"VirginiatechApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
VirginiatechApp::registerApps()
{
  registerApp(VirginiatechApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
VirginiatechApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  VirginiatechApp::registerAll(f, af, s);
}
extern "C" void
VirginiatechApp__registerApps()
{
  VirginiatechApp::registerApps();
}
