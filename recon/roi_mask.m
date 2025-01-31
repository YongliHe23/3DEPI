x=linspace(-45,44,90);y=linspace(-45,44,90);z=linspace(-45,44,90);
[xx,yy,zz]=meshgrid(x,y,z);
r=xx.^2+yy.^2+zz.^2;
iv=r<8^2;
roi=iv(:,:,16:75);