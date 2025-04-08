var usernameController = document.querySelector('input[type="text"]#username');
var passwordController = document.querySelector('input[type="password"]#password');
var buttonLogin = document.querySelector('button#login');

buttonLogin.addEventListener("click",function(){
    var username = usernameController.value;
    var password = passwordController.value;
    if(username == "root" && password == "password123"){
        window.alert("Selamat anda berhasil login");
    }else{
        window.alert("Username / Password Salah");
    }
});