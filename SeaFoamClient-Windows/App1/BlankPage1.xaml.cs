using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;


using Windows.Storage.Streams;
using Windows.Networking;
using Windows.Networking.Sockets;
using System.Text;
using Windows.UI.Popups;

using Newtonsoft.Json;


// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=234238

namespace App1
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class BlankPage1 : Page
    {
        public static StreamSocket mySocket = new StreamSocket();

        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            mySocket = e.Parameter as StreamSocket;
        }

        public BlankPage1()
        {
            this.InitializeComponent();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                DataWriter dw = new DataWriter(mySocket.OutputStream);
                MessageDisplay.Text = "yes";
            }
            catch
            {
                MessageDisplay.Text = "no";
            }

        }
    }
}
