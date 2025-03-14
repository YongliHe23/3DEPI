x=linspace(-45,44,90);y=linspace(-45,44,90);z=linspace(-45,44,90);
[xx,yy,zz]=meshgrid(x,y,z);
[x0,y0,z0]=deal(-2,0,0);
r=(xx-x0).^2+(yy-y0).^2+(zz-z0).^2;
iv=r<8^2;
roi=iv(:,:,16:75);

ball=r<36^2;