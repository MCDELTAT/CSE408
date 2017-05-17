% config and open serial port
delete(instrfind);
obj = serial('/dev/ttyUSB1','BaudRate',57600);
fopen(obj);
% where the data byte are located in my packet
lightbyte = 14;
accelbyte = 16;
packetSize = 17;
i = 0;
X = 0;
Light = 0;
Accel = 0;

% read the initial whole packet
Packet = fread(obj, packetSize);  

while true
   if Packet(1,1) == 126 && Packet(2, 1) == 69 && Packet(7, 1) == 7
       % remove the data from the packet
       X = [X i];
       l = (255 * Packet(lightbyte-1, 1) + Packet(lightbyte, 1));
       a = (Packet(accelbyte-1, 1) + Packet(accelbyte, 1));
       Light = [Light l];
       Accel = [Accel a];
       %Packet = [Packet(2:end, 1); fread(obj, 1)];
   else     
       % transpose to match dimensions  
       Packet = [Packet(2:end, 1); fread(obj, 1)];
       continue;
   end
   
   % plot the data
   plot(X, Light, 'r-o', X, Accel, 'g-*');
   title('Light Sensor');
   drawnow;
   pause(0.1);
   
   % alert to theft (change in light or accel)
   if(1 < 800 || a < 470 || a > 530)
      %disp('The mote has been stolen'); 
   end
   
   % get message and validate
   Packet = fread(obj, packetSize);
   
   %loop index increments for each point plotted
   i = i + 1;
end
try
fclose(obj);
catch
end  