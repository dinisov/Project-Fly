clear

pkg load instrument-control;

t = tcpclient('127.0.0.1',65432);

for i = 1:5

    write(t,'E');
    
    WaitSecs(1);

    write(t,'S');

    WaitSecs(1);

end