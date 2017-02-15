package bean;

public class FlightInfo {

		private int id;			   //data id
		private String name;       //flight number
		private double lon;       //longitude
		private double lat;           //latitude
		private int ori;     //orientation
		public FlightInfo(){
			
		}
		public FlightInfo(int id,String name,double lon,double lat,int ori){
			this.id=id;
			this.name=name;
			this.lon=lon;
			this.lat=lat;
			this.ori=ori;
		}
		public int getId(){
			return id;
		}
		public void setId(int id){
			this.id=id;
		}
		
		public String getName(){
			return name;
		}
		public void setName(String name){
			this.name=name;
		}

		public double getLon(){
			return lon;
		}
		public void setLon(double lon){
			this.lon=lon;
		}
		
		public double getLat(){
			return lat;
		}
		public void setLat(double lat){
			this.lat=lat;
		}
		
		public int getOri(){
			return ori;
		}
		public void setOri(int ori){
			this.ori=ori;
		}
}
