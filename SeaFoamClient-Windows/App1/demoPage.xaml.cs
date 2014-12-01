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

    public class ChatRoomInfo
    {
        public string name;
        public string userID; // do i need this?
        public string result;
        public Dictionary<string, string> desc; // error message
    }

    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class demoPage : Page
    {
        public static StreamSocket mySocket = new StreamSocket();
        public string myUserID;

        public demoPage(StreamSocket sockt, string userID)
        {
            mySocket = sockt;
            myUserID = userID;
            this.InitializeComponent();
        }

        //public async void addChatroom()
        //{
        //    //{action:ADD_CHAT, args:name, userID:1234}
        //    // {action:LIST_CHATS, args:, userID:1234}
        //    DataWriter dw = new DataWriter(mySocket.OutputStream);
        //    // send info to socket
        //    dw.WriteString("{action:ADD_CHAT, args:" + MessageBox.Text + ", userID:"+ myUserID   + "}"); //Tid|tid
        //    await dw.StoreAsync();


        //    DataReader reader = new DataReader(mySocket.InputStream);
        //    reader.InputStreamOptions = InputStreamOptions.Partial;
        //    await reader.LoadAsync(1024);
        //    string data = string.Empty;
        //    while (reader.UnconsumedBufferLength > 0)
        //    {
        //        data += reader.ReadString(reader.UnconsumedBufferLength);
        //        ChatRooms.Text += "\n\n" + data;
        //    }
        //    ChatRooms.Text += "DEBUG: " + data + " :DEBUG";
        //}

        //private async void updateChatrooms()
        //{
        //        // {action:LIST_CHATS, args:, userID:1234}
        //        DataWriter dw = new DataWriter(mySocket.OutputStream);
        //        // send info to socket
        //        dw.WriteString("{action:LIST_CHATS, args:, userID:"+myUserID+"}"); //Tid|tid
        //        await dw.StoreAsync();
                

        //        DataReader reader = new DataReader(mySocket.InputStream);
        //        reader.InputStreamOptions = InputStreamOptions.Partial;
        //        await reader.LoadAsync(1024);
        //        string data = string.Empty;
        //        while (reader.UnconsumedBufferLength > 0)
        //        {
        //            data += reader.ReadString(reader.UnconsumedBufferLength);
        //            //string output = JsonConvert.SerializeObject(data);
        //            //ChatRoomInfo l = JsonConvert.DeserializeObject<ChatRoomInfo>(data);
        //            //ChatRooms.Text += "\n\n" + data;
        //        }
        //        ChatRooms.Text += "BLAHBLAHBLAH";

        //}

        //private void Button_Click(object sender, RoutedEventArgs e)
        //{
        //    addChatroom();
        //}

        //private void Button_Click_1(object sender, RoutedEventArgs e)
        //{
        //    updateChatrooms();
        //}

        private void hyperlink_Click(object sender, RoutedEventArgs e)
        {
            Window.Current.Content = new demoChatroom(mySocket);
        }

    }
}
