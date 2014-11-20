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
    ///
    public class LoginInfo
    {
        string action;
        public string userID; // do i need this?
        public string result;
        public Dictionary<string, string> desc; // error message
    }

    public class RegisterInfo
    {
        string action;
        string userID; // do i need this?
        public string result;
        public Dictionary<string,string> desc; // error message
    }
    public sealed partial class MainPage : Page
    {
        // some public vars
        public static StreamSocket mySocket = new StreamSocket();
        public bool isAuthenticated = false;

        public MainPage()
        {
            this.InitializeComponent();
            makeSocket();
        }

        public async void makeSocket()
        {
            try 
            {
                await mySocket.ConnectAsync(new HostName("50.63.60.10"), "534", SocketProtectionLevel.PlainSocket);
            }
            catch 
            {
                System.Diagnostics.Debug.WriteLine("failed.");
            }
            
        }

        private void login_Click(object sender, RoutedEventArgs e)
        {
            check_login();
        }

        private async void authenticateUser()
        {

            DataWriter dw = new DataWriter(mySocket.OutputStream);
            // send login info to socket
            dw.WriteString("{action:LOGIN, args:"+usernameInput.Text+"|"+passwordInput.Password+"}"); //Tid|tid
            await dw.StoreAsync();

            DataReader reader = new DataReader(mySocket.InputStream);
            reader.InputStreamOptions = InputStreamOptions.Partial;
            await reader.LoadAsync(1024);
            string data = string.Empty;
            while (reader.UnconsumedBufferLength > 0)
            {
                data += reader.ReadString(reader.UnconsumedBufferLength);
            }

            // parse the string
            string output = JsonConvert.SerializeObject(data);
            LoginInfo l = JsonConvert.DeserializeObject<LoginInfo>(data);
            System.Diagnostics.Debug.WriteLine(l.result);

            /* moved here due to asynconousness*/
            if (l.result == "SUCCESS")
            {
                Windows.UI.Popups.MessageDialog messageDialog =
                    new Windows.UI.Popups.MessageDialog("login succcessful, welcome " + usernameInput.Text);
                await messageDialog.ShowAsync();

                // go to the next page
                /* probably should fix this up */
                //this.Frame.Navigate(typeof(BlankPage1), mySocket);
                System.Diagnostics.Debug.WriteLine(l.userID);
                Window.Current.Content = new BlankPage1(mySocket, l.userID);
            }
            else
            {
                Windows.UI.Popups.MessageDialog messageDialog =
                    new Windows.UI.Popups.MessageDialog("ERROR: " + l.desc["info"]);
                await messageDialog.ShowAsync();
                usernameInput.Text = "";
                passwordInput.Password = "";
            }
        }

        private async void RegisterUser()
        {
            DataWriter ddw = new DataWriter(mySocket.OutputStream);
            // send login info to socket
            //{action:CREATE_ACCOUNT, args:username|password}
            ddw.WriteString("{action:CREATE_ACCOUNT, args:" + usernameInput.Text + "|" + passwordInput.Password+"|"+emailInput.Text+"}"); //Tid|tid
            await ddw.StoreAsync();

            /* check serverside for stuff and read the output*/
            DataReader reader = new DataReader(mySocket.InputStream);
            reader.InputStreamOptions = InputStreamOptions.Partial;
            await reader.LoadAsync(1024);
            string data = string.Empty;
            while (reader.UnconsumedBufferLength > 0)
            {
                data += reader.ReadString(reader.UnconsumedBufferLength);
            }
            tempBox.Text = data;
            /* do some kind of check on user input*/
            // clean up this smelly code if have the time
            if (String.IsNullOrEmpty(usernameInput.Text))
            {
                Windows.UI.Popups.MessageDialog messageDialog =
                    new Windows.UI.Popups.MessageDialog("You must enter a username");
                await messageDialog.ShowAsync();
            }
            else if (String.IsNullOrEmpty(passwordInput.Password))
            {
                Windows.UI.Popups.MessageDialog messageDialog =
                    new Windows.UI.Popups.MessageDialog("You must enter a password");
                await messageDialog.ShowAsync();
            }
            else if (String.IsNullOrEmpty(emailInput.Text))
            {
                Windows.UI.Popups.MessageDialog messageDialog =
                    new Windows.UI.Popups.MessageDialog("You must enter an email");
                await messageDialog.ShowAsync();
            }
            else
            {
                // read serverside stuff
                string output = JsonConvert.SerializeObject(data);
                RegisterInfo r = JsonConvert.DeserializeObject<RegisterInfo>(data);
                System.Diagnostics.Debug.WriteLine(r.result);
                //display message
                if (r.result == "SUCCESS")
                {
                    Windows.UI.Popups.MessageDialog messageDialog =
                        new Windows.UI.Popups.MessageDialog("User Registered");
                    await messageDialog.ShowAsync();
                    usernameInput.Text = "";
                    passwordInput.Password = "";
                }
                else
                {
                    Windows.UI.Popups.MessageDialog messageDialog =
                        new Windows.UI.Popups.MessageDialog("ERROR: " + r.desc["info"]);
                    await messageDialog.ShowAsync();
                    usernameInput.Text = "";
                    passwordInput.Password = "";
                }
            }
        }

        private async void check_login()
        {
            if (String.IsNullOrEmpty(usernameInput.Text))
            {
                Windows.UI.Popups.MessageDialog messageDialog =
                    new Windows.UI.Popups.MessageDialog("You must enter a username");
                await messageDialog.ShowAsync();
            }
            else if (String.IsNullOrEmpty(passwordInput.Password))
            {
                Windows.UI.Popups.MessageDialog messageDialog =
                    new Windows.UI.Popups.MessageDialog("You must enter a password");
                await messageDialog.ShowAsync();
            }
            else 
            { 
                /* replace with server side code */
                // trim whitespace ? //
                authenticateUser();
            }
        }

        private void NewUserButton_Click(object sender, RoutedEventArgs e)
        {
            RegisterUser();

            /* Would be nice to have */
            /* need to learn how to pass to popup*/
            /*
            Popup popup = new Popup();
            popup.Height = 300;
            popup.Width = 400;
            popup.VerticalOffset = 100;
            PopUpUserControl control = new PopUpUserControl();
            popup.Child = control;
            popup.IsOpen = true;
            */


        }
    }
}
