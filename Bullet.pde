public class Bullet{
    float x, y, angle, size;
    PVector velocity;

    public Bullet(float x, float y, float angle){
        this.x = x;
        this.y = y;
        this.angle = angle - PI/2;
        this.size = 5;
        velocity = PVector.fromAngle(this.angle);
        velocity.mult(8);
    }

    public void travel(){
        x += velocity.x;
        y += velocity.y;
    }

    public boolean bound(){
        if (x + size < 0){
            return true;
        }
        else if (x - size > width){
            return true;
        }

        if (y + size < 0){
            return true;
        }
        else if (y - size > height){
            return true;
        }

        return false;
    }

    public void checkHit(){
        for (Asteroid a : asteroids){
            float distance = dist(a.getX(), a.getY(), x, y);
            if (distance < a.getSize()/2){
                a.explode();
                x = width + 200;
                break;
            }
        }
    }

    public void show(){
        pushMatrix();
        ellipseMode(CENTER);
        translate(x, y);
        travel();
        noStroke();
        fill(255);
        ellipse(0, 0, size, size);
        popMatrix();
        checkHit();
    }

    public float getX(){
        return x;
    }

    public float getY(){
        return y;
    }

}
