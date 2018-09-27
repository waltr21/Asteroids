public class Asteroid{
    float x, y, size;
    int level, maxLevel;
    PVector velocity;
    Ship p;

    /**
     * Constructor for the Asteroid class.
     * @param x     X pos of the asteroid
     * @param y     Y pos of the asteroid
     * @param level Level of asteroid (1-3)
     * @param p     Current player (Used for x/y refernecing)
     */
    public Asteroid(float x, float y, int level, Ship p){
        this.x = x;
        this.y = y;
        this.size = 30 * level;
        this.level = level;
        this.maxLevel = 3;
        this.p = p;
        this.velocity = PVector.fromAngle(random(-PI, PI));
        this.velocity.mult(((maxLevel+1) - level) * 0.8);
    }


    /**
     * Bound the Asteroid to stay inside of the screen.
     */
    public void bound(){
        if (x + size < 0){
            x = width + size/2;
        }
        else if (x - size > width){
            x = 0 - size/2;
        }

        if (y + size < 0){
            y = height + size/2;
        }
        else if (y - size > height){
            y = 0 - size/2;
        }
    }

    public void travel(){
        x += velocity.x;
        y += velocity.y;
    }

    public void checkHit(){
        float distance = dist(x, y, p.getX(), p.getY());
        //System.out.println(distance);
        if (distance < size/2 + p.getSize()){
            p.setHit();
        }
    }

    public void explode(){
        if (level > 1){
            int numChildren = 2;
            asteroids.remove(this);
            for (int i = 0; i < numChildren; i++){
                asteroids.add(new Asteroid(x, y, level - 1, player));
            }
        }
        else{
            asteroids.remove(this);
        }
    }

    public int getScore(){
        if (level == 1)
            return 100;
        else if (level == 2)
            return 50;
        else
            return 20;

    }

    public void show(){
        pushMatrix();
        checkHit();
        travel();
        bound();
        noFill();
        stroke(255);
        ellipseMode(CENTER);
        translate(x, y);
        ellipse(0, 0, size, size);
        popMatrix();
    }

    public float getX(){
        return x;
    }

    public float getY(){
        return y;
    }

    public float getSize(){
        return size;
    }
}
