<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model  ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>

          <a-col :span="24" >
            <a-form-model-item label="專案名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="projectId">
              <a-select v-model="model.projectId" @change="getAll" placeholder="請選擇專案"  :disabled=editable>
                <a-select-option v-for="project in projects":value="project.value"  >{{project.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="實例名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="instanceName">
              <a-input v-model="model.instanceName" placeholder="請輸入實例名稱"  :disabled=editable></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
              <a-input v-model="model.represent" placeholder="請輸入描述"  :disabled=editable></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" >
            <a-form-model-item label="映像檔" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="imgId">
             <!-- <j-dict-select-tag type="list" v-model="model.imgId" dictCode="" placeholder="請選擇映像檔id" />-->
              <a-select v-model="model.imgId"  placeholder="請選擇映像檔" :disabled=editable>
                <a-select-option v-for="imgs in imgIds":value="imgs.value" >{{imgs.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="刪除實例時是否刪除卷" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="isDelete">
              <j-dict-select-tag type="radioButton" v-model="model.isDelete" dictCode="is_delete" :disabled=editable placeholder="請選擇刪除實例時是否刪除卷" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="虛擬硬體樣板" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="flavorId">
              <!--<j-dict-select-tag type="list" v-model="model.flavorId" dictCode="" placeholder="請選擇虛擬硬體樣板id" />-->
              <a-select v-model="model.flavorId"  placeholder="請選擇虛擬硬體樣板" :disabled=justable>
                <a-select-option v-for="flavors in flavorIds":value="flavors.value">{{flavors.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="合約日期啟" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="startTime">
              <j-date v-model="model.startTime" placeholder="請選擇開始時間" date-format="YYYY-MM-DD" style="width: 60%" :disabled=justable></j-date>
            <!--  <a-range-picker :default-value="[model.startTime, model.endTime]"  style="width: 100%"></a-range-picker>-->
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="合約日期迄" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="endTime">
              <j-date v-model="model.endTime" placeholder="請選擇終止時間" date-format="YYYY-MM-DD" style="width: 60%" :disabled=justable></j-date>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="安全群組" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="securityName">
              <!--<j-dict-select-tag type="list" v-model="model.securityName" dictCode="" placeholder="請選擇安全群組" />-->
              <a-select v-model="model.securityName"  placeholder="請選擇安全群組" :disabled=justable>
                <a-select-option v-for="securitys in securityNames":value="securitys.text" >{{securitys.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="網路" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="networkId">
              <!--<j-dict-select-tag type="list" v-model="model.networkId" dictCode="" placeholder="請選擇網路" />-->
              <a-select v-model="model.networkId"  placeholder="請選擇網路" :disabled=editable>
                <a-select-option v-for="networks in networkIds":value="networks.value" >{{networks.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="秘鑰" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="keypairsId">
              <a-select v-model="model.keypairsId"  placeholder="請選擇秘鑰" style="width: 60%" :disabled=editable >
                <a-select-option v-for="key in keyNames":value="key.value" >{{key.text}}</a-select-option>
              </a-select>
              <a-button @click="downPrivateKey" type="primary">下載秘鑰</a-button>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" v-show="showoption">
            <a-form-model-item label="審核意見" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="optionsText" >
              <a-textarea v-model="model.optionsText" placeholder="請輸入審核意見" ></a-textarea>
            </a-form-model-item>
          </a-col>
        </a-row>
      </a-form-model>
    </j-form-container>
  </a-spin>
</template>

<script>

  import { httpAction, getAction ,downloadFile} from '@/api/manage'
  import { validateDuplicateValue } from '@/utils/util'
  import  moment from "moment"

  export default {
    name: 'OsApplyForm',
    components: {
    },
    props: {
      //表單禁用
      disabled: {
        type: Boolean,
        default: false,
        required: false


      }
    },
    data () {
      return {
        model:{
         },
        labelCol: {
          xs: { span: 24 },
          sm: { span: 5 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        validatorRules: {

          projectId: [
            { required: true, message: '請選擇專案!'},
          ],
           instanceName: [
              { required: true, message: '請輸入實例名稱!'},
           ],
           imgId: [
              { required: true, message: '請輸入映像檔id!'},
           ],
           flavorId: [
              { required: true, message: '請輸入虛擬硬體樣板id!'},
           ],
          securityName: [
            { required: true, message: '請選擇安全群組!'},
          ],
          networkId: [
              { required: true, message: '請選擇網路'},
            ],
            startTime: [
              { required: true, message: '請輸入開始時間!'},
            ],
            endTime: [
              { required: true, message: '請輸入結束時間!'},
            ]

        },
        url: {
          add: "/os/osApply/add",
          edit: "/os/osApply/edit",
          queryById: "/os/osApply/queryById",
          readData: "/os/osApply/readData",
          getProject: "/os/osApply/getProject",
          getImg: "/os/osApply/getImg",
          getFlavor: "/os/osApply/getFlavor",
          getSecurity: "/os/osApply/getSecurity",
          getNetwork: "/os/osApply/getNetwork",
          adjust: "/os/osApply/adjust",
          getKeyPairs: "/os/osApply/getKeyPairs",
          agree: "/os/osOption/agree",
          refuse: "/os/osOption/refuse",
          getPrivateKey: "openstack/osKeyPairs/getPrivateKey",
        },
        projects:[],
        imgIds:[],
        flavorIds:[],
        securityNames:[],
        networkIds:[],
        keyNames:[],
        keyName:"",
        privateKey:"",
        dateFormat:'YYYY-MM-DD',
        editable: false,
        justable: false,
        showoption: false
      }
    },
    computed: {
      formDisabled(){
        return this.disabled
      },

    },
    created () {
       //備份model原始值
     // this.getdata();

      this.modelDefault = JSON.parse(JSON.stringify(this.model));
      this.getProjects(this.modelDefault);
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
        if(this.model.id){
          this.getAll();
        }
        this.showoption = this.model.showoption;
        if(this.model.options=="1" || (this.model.options=="2" && this.model.status!=null) ){
          this.editable=true
          this.justable=true
        }else if(this.model.options=="2" && this.model.status==null){
          this.editable=true
          this.justable=false
        }
      },
      submitForm () {
        const that = this;
        this.projects.forEach((r)=>{
          if(r.value==that.model.projectId){
            that.model.projectName = r.text;
          }
        })
        this.imgIds.forEach((r)=>{
          if(r.value==that.model.imgId){
            that.model.imgName = r.text;
          }
        })
        this.flavorIds.forEach((r)=>{
          if(r.value==that.model.flavorId){
            that.model.flavorName = r.text;
          }
        })

        // 觸發表單驗證
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            let httpurl = '';
            let method = '';
            if(!this.model.id){
              httpurl+=this.url.add;
              method = 'post';
            }else{
              httpurl+=this.url.edit;
               method = 'put';
            }
            httpAction(httpurl,this.model,method).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
            })
          }

        })
      },
      //同意
      agree(){
        let that = this;
        let method = "post";
        this.model.applyType = "1";
        this.model.optionsType="1";
        let httpurl = this.url.agree;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
        })
      },
      //拒絕
      refuse(){
        const that = this;
        this.model.applyType = "1";
        this.model.optionsType="0";
        let method = "post";
        let httpurl = this.url.refuse;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.$emit('ok');
            that.loadData();
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
        })

      },

      getProjects(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getProject;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.projects.push({
                value:r.projectId,
                text:r.projectName,
              })
            })
          }
        })
      },
      getAll(){
        this.getImgs();
        this.getNetworkIdsNew();
        this.getFlavorIds();
        this.getSecurityNames();
        this.getPrivateKeys();
      },
      getImgs(){
        this.imgIds=[];
        let record = this.model;
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getImg;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.imgIds.push({
                value:r.imgId,
                text:r.imgName
              })
            })
          }
        })
      },
      getFlavorIds(){
        this.flavorIds=[];
        let record = this.model;
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getFlavor;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.flavorIds.push({
                value:r.flavorId,
                text:r.flavorName
              })
            })
          }
        })
      },
      getSecurityNames(){
        this.securityNames=[];
        let record = this.model;
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getSecurity;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.securityNames.push({
                value:r.value,
                text:r.securityName
              })
            })
          }
        })
      },
      getNetworkIdsNew(){
        this.networkIds=[];
        let record = this.model;
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getNetwork;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.networkIds.push({
                value:r.networkId,
                text:r.networkName
              })
            })
          }
        })
      },
      getPrivateKeys(){
        this.keyNames=[];
        let method = "post";
        let httpurl = this.url.getKeyPairs;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.keyNames.push({
                value:r.keypairsId,
                text:r.keyName,
                key:r.privateKey
              })
            })
          }
        })
      },
      downPrivateKey(){
        this.keyNames.forEach((r)=>{
          if(r.value==this.model.keypairsId){
            this.model.keyName = r.text;
            this.model.privateKey = r.key;
          }
        })
        let keyName =  this.model.keyName;
        downloadFile(this.url.getPrivateKey,keyName+'.pem',this.model);
      },
    }
  }
</script>