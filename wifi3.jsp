<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!--선언, 언어는 java, content의 타입은 text/html, utf-8형식 사용, 인코딩 UTF_8형식-->
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.FileReader" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.IOException" %>

<html>

<head>
    <meta charset="UTF-8">  <!--utf8 형식을 사용-->
</head>

<body>
    <%
	/*try catch로 예외처리*/
    try{
        /*웹 어플리케이션에 대한 정보를 다룰 수 있는 application 기본 객체를 이용, 웹 어플리케이션상에 위치한 파일 자원을 얻어온다.*/
        String filePath = application.getRealPath("./4/wifilist.txt");  /*상대경로로 지정해서 wifilist.txt를 가져옴*/
        BufferedReader br = new BufferedReader(new FileReader(filePath)); /*파일에 대해서 bufferedreader br 생성*/
        BufferedReader br2 = new BufferedReader(new FileReader(filePath)); /*파일에 대해서 bufferedreader br2 생성*/
        String readtxt;
        String readtxt2; /*br2로 파일을 readtxt2에서 읽어와서 저장*/
        int totalLineCnt = 0;  /*총 라인수를 알기 위해서 totalLineCnt를 선언하고 0으로 초기화*/
        if ((readtxt = br.readLine()) == null || (readtxt2 = br2.readLine()) == null) { /*파일을 br로 한 줄씩 읽어서 readtxt에 저장, 만약 null이면 if문 수행*/
            out.println("빈 파일입니다<br>");
            return;
        }
        while ((readtxt2 = br2.readLine()) != null) { /*파일을 br2로 한 줄씩 읽어서 readtxt에 저장, null이 아니면 totalLineCnt를 ++한다.*/
            totalLineCnt++;
        }
        double lat = 37.3860521;   /*위도, 경도 선언, 융기원의 위도,경도 저장*/
        double lng = 127.1214038;   
        int LineCnt = 0;  /*LineCnt 선언, 0으로 초기화, readtxt의 라인 수*/
        int cntPT = 10;  /*한 페이지 당 테이블에 가져올 행 개수.*/
        if (request.getParameter("cntPT") != null) { /*cntPT를 parameter로 받아와서 null이 아니면 int로 변환*/
            cntPT = Integer.parseInt(request.getParameter("cntPT"));   
        } 
        int startRow = 0;  /*각 페이지의 테이블의 시작하는 행 값.*/
        int endRow = 0;  /*각 페이지의 테이블의 끝나는 행 값.*/
        String pageNum = request.getParameter("pageNum");  /*PageNum을 parameter로 받아온다*/
        if(pageNum == null) { /*PageNum이 Null이면 "1"로 저장.*/
            pageNum = "1";
        }
        if(pageNum != 1) {
            startRow = pageNum*cntPT - cntPT;
        }
        List<aa> a = new ArrayList<>();
        a = service.selectPage(startRow,cntPT);
        int currentPage = Integer.parseInt(pageNum); /*PageNum을 parameter로 받아와서 정수로 변환 후, 현재 페이지인 currentPage에 저장*/
    %>
        <table border=1px>  <!--테이블 열기, 테두리 1픽셀-->
         <tr>  <!--1행시작, 5열을 생성, 가운데 정렬-->
            <td style=text-align:center;>번호</td>
            <td style=text-align:center;>주소</td>
            <td style=text-align:center;>위도</td>
            <td style=text-align:center;>경도</td>
            <td style=text-align:center;>거리</td>
         </tr> <!--1행 닫기--> 
    <%
        while ((readtxt = br.readLine()) != null) { /*파일을 br로 한 줄씩 읽어서 readtxt에 저장, null이 아니면 while문 수행*/
            LineCnt++; /*첫 줄은 헤드 부분이니까 값을 가져오지 않도록 ++해준다.*/
         
            startRow = (currentPage - 1) * cntPT + 1; /*현재 페이지 - 1에 페이지 당 행 개수를 곱하고 1을 더하면 페이지의 첫 행값*/
            endRow = currentPage*cntPT; /*현재 페이지에 페이지당 행 수를 곱하면 페이지의 끝 행 값*/
            String[] field = readtxt.split("\t");  /*배열 field를 선언하고, readtxt를 탭을 구분자로 잘라서 요소 값으로 입력*/
            /*위도와 경도를 뜻하는 field[12], field[13]의 값을 더블로 바꾸고 융기원의 위도,경도를 이용해 거리 계산*/
            double dist = Math.sqrt(Math.pow(Double.parseDouble(field[12]) - lat, 2) + Math.pow(Double.parseDouble(field[13]) - lng, 2));
            
            if (LineCnt <  startRow) continue;  /*LineCnt가 startRow보다 작으면 while문의 처음으로 돌아간다.*/
            if (LineCnt > endRow) break;  /*LineCnt가 endRow보다 크면 while문을 탈출한다*/
    %>
         <tr>  <!--while문이 수행되는 동안 행 생성, 5열 생성, 각 열에 해당 값을 출력한다.-->
            <td style=text-align:center;><%=LineCnt%></td>
            <!--번호-->
            <td style=text-align:center; width=><%=field[9]%></td>
            <!--주소-->
            <td style=text-align:center;><%=field[12]%></td>
            <!--위도-->
            <td style=text-align:center;><%=field[13]%></td>
            <!--경도-->
            <td style=text-align:center;><%=dist%></td>
            <!--거리-->
         </tr>   <!--행 닫기-->
    <%
        }
    %>
        </table>  <!--표 닫기-->
    <%
    if (totalLineCnt > 0) { /*파일의 총 라인 수가 0보다 크면 if문 수행*/
        int pageCount = totalLineCnt / cntPT + (totalLineCnt%cntPT==0?0:1); /*총 페이지 수*/
        int pageBlock = 10; /* <<부터 >>까지 들어갈 페이지 개수*/
        /* <<부터 >>까지 들어갈 페이지 중 처음 페이지*/
        int startPage = ((int)(currentPage/pageBlock)-(currentPage%pageBlock==0?1:0))*pageBlock+1; 
        int endPage = startPage + pageBlock - 1;  /* <<부터 >>까지 들어갈 페이지 중 마지막 페이지*/
        if (endPage > pageCount) { /* endPage가 총 페이지 개수 보다 커지면 총페이지개수로 저장*/
            endPage = pageCount;
        }
                
        int nPage = startPage-pageBlock;  /* <<에 연결될 페이지 넘버*/
        if (nPage == -9) { /* <<에 연결될 페이지 넘버가 -9일때 (맨 처음 값) 1로 저장.*/
            nPage = 1;
        }
    %>
        <table style=margin-left:120px;>
         <tr>  <!-- << 에 1페이지를 연결해서 <<을 누르면 1페이지로 돌아감.-->
            <td style=text-align:center; width=20px;><a href="http://192.168.23.17:8080/4/wifi3.jsp?pageNum=1&cntPT=<%=cntPT%>">&lt;&lt;</a></td>
            <!-- < 에 연될될 페이지  -->
            <td style=text-align:center; width=20px;><a href="http://192.168.23.17:8080/4/wifi3.jsp?pageNum=<%=nPage%>&cntPT=<%=cntPT%>">&lt;</a></td>
    <%         
        for (int i = startPage; i <= endPage; i++) {  /* i페이지에 연결될 url*/
    %>      <td style=text-align:center; width=20px;><a href="http://192.168.23.17:8080/4/wifi3.jsp?pageNum=<%=i%>&cntPT=<%=cntPT%>"><%= i %></a></td>
    <%
        }           
        if (endPage < pageCount) {  /* > 에 연결될 페이지 */
    %>
            <td style=text-align:center; width=20px;><a href="http://192.168.23.17:8080/4/wifi3.jsp?pageNum=<%=startPage+pageBlock%>&cntPT=<%=cntPT%>">&gt;</a></td>
    <%		
        }
    %>
         <!-- >> 에 마지막 페이지를 연결해서 >> 을 누르면 마지막 페이지로 돌아감.-->
        <td style=text-align:center; width=20px;><a href="http://192.168.23.17:8080/4/wifi3.jsp?pageNum=<%=pageCount%>&cntPT=<%=cntPT%>">&gt;&gt;</a></td></tr></table>
    <%
    }
    } catch (IOException e) {  /*예외가 발생했을 때 실행*/
        e.printStackTrace();
    }
    %>
</body>

</html>