using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(Control_de_Inventario.Startup))]
namespace Control_de_Inventario
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
